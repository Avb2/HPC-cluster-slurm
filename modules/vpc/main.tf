locals {
  subnet_names = ["Private", "Public"]
  cidrs = ["10.0.1.0", "10.0.2.0"]
  az = "us-east-1a"
}







#### VPC

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}







### Internet gateway / elastic ip / NAT

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_eip" "eip" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.subnet[1].id

  tags = {
    Name = "NAT GW"
  }

  depends_on = [aws_internet_gateway.gw]
}







##### Route tables

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}



resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id  = aws_nat_gateway.nat.id
  }
}








#### Subnets

resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "${local.cidrs[count.index]}/26"
  count = 2

  availability_zone = local.az

  tags = {
    Name = "${local.subnet_names[count.index]} Subnet"
  }
}







### Route Tables Association

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.subnet[1].id  # Public subnet
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.subnet[0].id  # Private subnet
  route_table_id = aws_route_table.private_rt.id
}


