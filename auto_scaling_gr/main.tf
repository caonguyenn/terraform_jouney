provider "aws" {
  region                   = "ap-southeast-1"
  shared_config_files      = ["/home/vagrant/.aws/config"]
  shared_credentials_files = ["/home/vagrant/.aws/credentials"]
}

data "aws_availability_zones" "available" {
  state = "available"
}


module "vpc" {
  source                 = "../modules/vpc"
  cidr_block             = "10.0.0.0/16"
  aws_availability_zones = data.aws_availability_zones.available.names
  vpc_name               = "VPC - Auto Scaling Group"
}

module "security_group" {
  source      = "../modules/security_sg"
  vpc_id      = module.vpc.vpc_id
  allow_ports = ["22", "80", "443"]
}

# Create Launch Template
resource "aws_launch_template" "example" {
  name_prefix   = "example-launch-template"
  image_id      = "ami-0d07675d294f17973"
  instance_type = "t2.micro"

  network_interfaces {
    security_groups = [module.security_group.security_group_id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              sudo systemctl start httpd
              sudo systemctl enable httpd
              echo "<h1>Welcome to the EC2 instance in AZ: $(hostname -f)</h1>" > /var/www/html/index.html
              EOF
  )

  tags = {
    Name = "ExampleInstance"
  }
  update_default_version = true
}


# Create Auto Scaling Group
resource "aws_autoscaling_group" "example" {
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1
  vpc_zone_identifier = module.vpc.subnet_id

  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "example-asg"
    propagate_at_launch = true
  }
  # Auto Scaling Group Update Policy
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }
  health_check_type = "EC2"
}
