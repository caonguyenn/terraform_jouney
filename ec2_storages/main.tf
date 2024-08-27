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

module "ebs" {
  source             = "./ebs_module"
  subnet_id          = aws_subnet.storage_subnet.id
  security_groups_id = aws_security_group.storage_sg.id
  ssh_key_name       = aws_key_pair.my_keypair.key_name
  availability_zone = data.aws_availability_zones.available.names[0]
}

module "efs" {
  source             = "./efs_module"
  subnet_id          = aws_subnet.storage_subnet.id
  security_groups_id = aws_security_group.storage_sg.id
  ssh_key_name       = aws_key_pair.my_keypair.key_name
  vpc_id = aws_vpc.storage_vpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
}