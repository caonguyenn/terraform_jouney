variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "allow_ports" {
  description = "Inbound ports"
  type        = list(string)
}