output "vpc_id" {
    description = "The ID of the VPC"
  value = aws_vpc.vpc.id
}

output "subnet_id" {
  description = "List of subnet ID"
  value = [for s in aws_subnet.subnet : s.id]
}

output "az_to_subnet_map" {
  value = { for az, subnet in aws_subnet.subnet : az => subnet.id }
}

