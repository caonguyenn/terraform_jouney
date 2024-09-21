provider "aws" {
  region                   = "ap-southeast-1"
  shared_config_files      = ["/home/vagrant/.aws/config"]
  shared_credentials_files = ["/home/vagrant/.aws/credentials"]
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "ssh_key" {
  source = "../modules/ssh_key"
}

module "vpc" {
  source                 = "../modules/vpc"
  cidr_block             = "20.0.0.0/16"
  aws_availability_zones = data.aws_availability_zones.available.names
  vpc_name               = "Instance store - VPC"
}

module "security_group" {
  source      = "../modules/security_sg"
  vpc_id      = module.vpc.vpc_id
  allow_ports = ["22"]
}

module "ebs" {
  source             = "./ebs_module"
  subnet_id          = module.vpc.subnet_id[0]
  security_groups_id = module.security_group.security_group_id
  ssh_key_name       = module.ssh_key.keypair_name
  availability_zone  = data.aws_availability_zones.available.names[0]
}

module "efs" {
  source             = "./efs_module"
  subnet_id          = module.vpc.subnet_id[0]
  security_groups_id = module.security_group.security_group_id
  ssh_key_name       = module.ssh_key.keypair_name
  vpc_id             = module.vpc.vpc_id
  availability_zone  = data.aws_availability_zones.available.names[0]
}