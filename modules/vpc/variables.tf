variable "cidr_block" {
    description = "cidr block for vpc"
  type = string
}

variable "aws_availability_zones" {
    description = "Availability Zones"
  type = list(string)
}

variable "vpc_name" {
  description = "Name of VPC"
  type = string
}