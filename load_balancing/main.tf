terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60.0"
    }
  }
}

provider "aws" {
  region                   = "ap-southeast-1"
  shared_config_files      = ["/home/vagrant/.aws/config"]
  shared_credentials_files = ["/home/vagrant/.aws/credentials"]
}

locals {
  az_to_subnet_map = { for az, subnet in aws_subnet.lb_subnet : az => subnet.id }
}

##############################################################################################
### Classic Load Balancer
##############################################################################################
module "clb_instances" {
  for_each = local.az_to_subnet_map

  source = "./ec2_module" # Path to your module

  availability_zone = each.key   # Pass the AZ
  subnet_id         = each.value # Pass the corresponding Subnet ID
  name              = "Classic Load Balancer"

  security_group_id = aws_security_group.lb_sg.id
  ssh_key_name      = aws_key_pair.my_keypair.key_name
}

# Get all EC2 instance IDs
locals {
  clb_instance_ids = [for instance in module.clb_instances : instance.instance_id]
}

resource "aws_elb" "classic_lb" {
  name = "classic-load-balancer"
  #   availability_zones = data.aws_availability_zones.available.names

  # Subnets where the ELB will be attached (can be from each AZ)
  subnets         = [for subnet in aws_subnet.lb_subnet : subnet.id]
  security_groups = [aws_security_group.lb_sg.id]

  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }

  instances = local.clb_instance_ids

  health_check {
    target              = "HTTP:80/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "ClassicLoadBalancer"
  }
}

##############################################################################################
### Application Load Balancer
##############################################################################################

module "alb_instances" {
  for_each = local.az_to_subnet_map

  source = "./ec2_module" # Path to your module

  availability_zone = each.key   # Pass the AZ
  subnet_id         = each.value # Pass the corresponding Subnet ID
  name              = "Application Load Balancer"

  security_group_id = aws_security_group.lb_sg.id
  ssh_key_name      = aws_key_pair.my_keypair.key_name
}

# Get all EC2 instance IDs
locals {
  alb_instance_ids = [for instance in module.alb_instances : instance.instance_id]
}

locals {
  alb_instance_map = { for idx, instance_id in local.alb_instance_ids : idx => instance_id }
}

resource "aws_lb_target_group" "alb_tg" {
  name     = "alb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.lb_vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = {
    Name = "ALB Target Group"
  }
}
resource "aws_lb" "application_lb" {
  name               = "application-load-balancer"
  internal           = false
  load_balancer_type = "application"
  subnets            = [for subnet in aws_subnet.lb_subnet : subnet.id]
  security_groups    = [aws_security_group.lb_sg.id]

  enable_deletion_protection = true

  tags = {
    Name = "ApplicationLoadBalancer"
  }
}

resource "aws_lb_listener" "app_lb_listener" {
  load_balancer_arn = aws_lb.application_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "alb_tg_attachment" {
  for_each = local.alb_instance_map

  target_group_arn = aws_lb_target_group.alb_tg.arn
  target_id        = each.value
  port             = 80
}