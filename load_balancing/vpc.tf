data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "lb_vpc" {
  cidr_block = "30.0.0.0/16"
  tags = {
    name = "vpc_for_LB"
  }
}

resource "aws_subnet" "lb_subnet" {
  for_each                = toset(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.lb_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.lb_vpc.cidr_block, 8, index(data.aws_availability_zones.available.names, each.key))
  map_public_ip_on_launch = true
  availability_zone       = each.value
  tags = {
    name = "public_subnet_for_LB_${each.key}"
  }
}

resource "aws_route_table" "lb_rtb" {
  vpc_id = aws_vpc.lb_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lb_igw.id
  }
}

resource "aws_internet_gateway" "lb_igw" {
  vpc_id = aws_vpc.lb_vpc.id
}

# Associate subnets with the route table
resource "aws_route_table_association" "lb_rtb_A" {
  for_each       = aws_subnet.lb_subnet
  route_table_id = aws_route_table.lb_rtb.id
  subnet_id      = each.value.id
}