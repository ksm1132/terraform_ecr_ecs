resource "aws_vpc" "ims_app" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "ims-app"
  }
}

#############public subnet

resource "aws_subnet" "public_0" {
  vpc_id = aws_vpc.ims_app.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1a"
}

resource "aws_subnet" "public_1" {
  vpc_id = aws_vpc.ims_app.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1c"
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
resource "aws_route_table_association" "public_0" {
  subnet_id = aws_subnet.public_0.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1" {
  subnet_id = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}


##############private subnet

resource "aws_subnet" "private_0" {
  vpc_id = aws_vpc.ims_app.id
  cidr_block = "10.0.65.0/24"
  availability_zone = "ap-northeast-1a"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "private_1" {
  vpc_id = aws_vpc.ims_app.id
  cidr_block = "10.0.66.0/24"
  availability_zone = "ap-northeast-1c"
  map_public_ip_on_launch = false
}

resource "aws_route_table" "private_0" {
  vpc_id = aws_vpc.ims_app.id
}

resource "aws_route_table" "private_1" {
  vpc_id = aws_vpc.ims_app.id
}

# resource "aws_route" "private_0" {
#   route_table_id = aws_route_table.private_0.id
#   nat_gateway_id = aws_nat_gateway.ims_app.id
#   destination_cidr_block = "0.0.0.0/0"
# }

# resource "aws_route" "private_1" {
#   route_table_id = aws_route_table.private_1.id
#   nat_gateway_id = aws_nat_gateway.ims_app.id
#   destination_cidr_block = "0.0.0.0/0"
# }

resource "aws_route_table_association" "private_0" {
  route_table_id = aws_route_table.private_0.id
  subnet_id = aws_subnet.private_0.id
}

resource "aws_route_table_association" "private_1" {
  route_table_id = aws_route_table.private_1.id
  subnet_id = aws_subnet.private_1.id
}

##################NAT GATEWAY  不要

# resource "aws_eip" "nat_gateway" {
#   depends_on = [aws_internet_gateway.ims_app]
# }
#
# resource "aws_nat_gateway" "ims_app" {
#   allocation_id = aws_eip.nat_gateway.id
#   subnet_id     = aws_subnet.public_0.id
#   depends_on = [aws_internet_gateway.ims_app]
# }


