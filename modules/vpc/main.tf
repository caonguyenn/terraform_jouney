resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
  tags = {
    name = var.vpc_name
  }
}

resource "aws_subnet" "subnet" {
  for_each                = toset(var.aws_availability_zones)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, index(var.aws_availability_zones, each.value))
  map_public_ip_on_launch = true
  availability_zone       = each.value
  tags = {
    name = "public-subnet-${each.value}"
  }
}

resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

# Associate subnets with the route table
resource "aws_route_table_association" "rtb_A" {
  for_each       = aws_subnet.subnet
  route_table_id = aws_route_table.rtb.id
  subnet_id      = each.value.id
}

