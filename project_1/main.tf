variable "key_name" {}

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

resource "aws_vpc" "example" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.example.id

  tags = {
    Name = "tf_internetgateway"
  }
}

resource "aws_subnet" "example" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.1.10.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "tf-example"
  }
}

resource "aws_route_table" "tf_route_table" {
  vpc_id = aws_vpc.example.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "name" {
  route_table_id = aws_route_table.tf_route_table.id
  subnet_id      = aws_subnet.example.id
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh into ec2 instance"
  vpc_id      = aws_vpc.example.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "allow_ssh"
  }
}

resource "tls_private_key" "my_keypair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.my_keypair.public_key_openssh
}


resource "aws_instance" "example" {
  ami           = "ami-0d07675d294f17973"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.example.id

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  key_name               = aws_key_pair.generated_key.key_name

  tags = {
    Name = "tf-example"
  }
}

output "private_key" {
  value     = tls_private_key.my_keypair.private_key_pem
  sensitive = true
}