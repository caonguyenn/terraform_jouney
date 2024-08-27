data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "storage_vpc" {
  cidr_block = "20.0.0.0/16"
  tags = {
    name = "vpc_for_storages"
  }
}

resource "aws_subnet" "storage_subnet" {
  vpc_id                  = aws_vpc.storage_vpc.id
  cidr_block              = "20.0.0.0/16"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    name = "public_subnet_for_storages"
  }
}

resource "aws_route_table" "storage_rtb" {
  vpc_id = aws_vpc.storage_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.storage_igw.id
  }
}

resource "aws_internet_gateway" "storage_igw" {
  vpc_id = aws_vpc.storage_vpc.id
}

resource "aws_route_table_association" "storage_rtb_A" {
  route_table_id = aws_route_table.storage_rtb.id
  subnet_id      = aws_subnet.storage_subnet.id
}