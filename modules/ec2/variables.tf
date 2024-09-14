variable "availability_zone" {
    description = "Availability Zone"
  type = string
}

variable "subnet_id" {
    description = "Subnet ID"
  type = string
}

variable "security_group_id" {
  description = "Sercurity Group ID"
  type = string
}

variable "ssh_key_name" {
  description = "SSH key name"
  type = string
}

variable "name" {
  description = "Instance Name"
  type = string
}