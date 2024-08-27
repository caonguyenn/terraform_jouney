
#Create an EC2 instance
resource "aws_instance" "EFS_instance" {
  ami           = "ami-0d07675d294f17973"
  instance_type = "t2.micro"
  availability_zone = var.availability_zone
  
  subnet_id = var.subnet_id
  vpc_security_group_ids = [var.security_groups_id]

  key_name = var.ssh_key_name
  tags = {
    name = "efs example instance"
  }
  user_data = <<-EOF
              #!/bin/bash
              yum install -y amazon-efs-utils
              mkdir /mnt/efs
              mount -t efs ${aws_efs_file_system.example_efs.id}:/ /mnt/efs
              EOF

  depends_on = [ aws_efs_file_system.example_efs ]
}

#Create a security group for the EFS
resource "aws_security_group" "efs_sg" {
  name        = "efs-sg"
  description = "Security group for EFS"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "efs-sg"
  }
}

#Create an EFS file system
resource "aws_efs_file_system" "example_efs" {
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name = "example-efs"
  }
}

#Create a mount target for the EFS file system in the same availability zone as the EC2 instance
resource "aws_efs_mount_target" "example" {
  file_system_id  = aws_efs_file_system.example_efs.id
  subnet_id       = var.subnet_id
  security_groups = [aws_security_group.efs_sg.id]
}