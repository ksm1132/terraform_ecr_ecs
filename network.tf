resource "aws_vpc" "ims_app" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "ims-app"
  }
}

#############public subnet

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.ims_app.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1a"
}

resource "aws_internet_gateway" "ims_app" {
  vpc_id = aws_vpc.ims_app.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.ims_app.id
}

resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  gateway_id = aws_internet_gateway.ims_app.id
  destination_cidr_block = "0.0.0.0/0"
}
resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


##############private subnet

resource "aws_subnet" "private" {
  vpc_id = aws_vpc.ims_app.id
  cidr_block = "10.0.64.0/24"
  availability_zone = "ap-northeast-1a"
  map_public_ip_on_launch = false
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.ims_app.id
}

resource "aws_route_table_association" "private" {
  route_table_id = aws_route_table.private.id
  subnet_id = aws_subnet.private.id
}


##################NAT GATEWAY

resource "aws_eip" "nat_gateway" {
  depends_on = [aws_internet_gateway.ims_app]
}

resource "aws_nat_gateway" "ims_app" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.public.id
  depends_on = [aws_internet_gateway.ims_app]
}

