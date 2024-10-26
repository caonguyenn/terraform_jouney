terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "Terraform_jouney"

    workspaces {
      name = "my-aws-app"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}