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

# resource "aws_route_table" "private_0" {
#  vpc_id = aws_vpc.ims_app.id
# }
#
# resource "aws_route_table" "private_1" {
#  vpc_id = aws_vpc.ims_app.id
# }

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.ims_app.id
}

#resource "aws_route" "private" {
#   route_table_id = aws_route_table.private.id
#   destination_cidr_block = "0.0.0.0/0"
# }


#resource "aws_route" "private_0" {
#   route_table_id = aws_route_table.private_0.id
#   nat_gateway_id = aws_nat_gateway.ims_app_0.id
#   destination_cidr_block = "0.0.0.0/0"
# }
#
#resource "aws_route" "private_1" {
#   route_table_id = aws_route_table.private_1.id
#   nat_gateway_id = aws_nat_gateway.ims_app_1.id
#   destination_cidr_block = "0.0.0.0/0"
# }


resource "aws_route_table_association" "private_0" {
  route_table_id = aws_route_table.private.id
  subnet_id = aws_subnet.private_0.id
}

resource "aws_route_table_association" "private_1" {
  route_table_id = aws_route_table.private.id
  subnet_id = aws_subnet.private_1.id
}

###################Endpoint

resource "aws_vpc_endpoint" "s3" {
  service_name = "com.amazonaws.${var.region}.s3"
  vpc_id       = aws_vpc.ims_app.id
  vpc_endpoint_type = "Gateway"
}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  route_table_id  = aws_route_table.private.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

resource "aws_security_group" "vpc_endpoint" {
  name = "vpc-endpoint-sg"
  vpc_id = aws_vpc.ims_app.id

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [aws_vpc.ims_app.cidr_block]
  }

  egress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [aws_vpc.ims_app.cidr_block]
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  service_name = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_id       = aws_vpc.ims_app.id
  vpc_endpoint_type = "Interface"
  subnet_ids = [aws_subnet.private_0.id, aws_subnet.private_1.id]
  security_group_ids = [aws_security_group.vpc_endpoint.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecr_api" {
  service_name = "com.amazonaws.${var.region}.ecr.api"
  vpc_id       = aws_vpc.ims_app.id
  vpc_endpoint_type = "Interface"
  subnet_ids = [aws_subnet.private_0.id, aws_subnet.private_1.id]
  security_group_ids = [aws_security_group.vpc_endpoint.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "cloudwatch_logs" {
  service_name      = "com.amazonaws.${var.region}.logs"
  vpc_id            = aws_vpc.ims_app.id
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.private_0.id, aws_subnet.private_1.id]
  security_group_ids = [aws_security_group.vpc_endpoint.id]
  private_dns_enabled = true
  tags = {
    Name = "CloudWatch Logs VPC Endpoint"
  }
}

resource "aws_vpc_endpoint" "ssm" {
  service_name = "com.amazonaws.${var.region}.ssm"
  vpc_id       = aws_vpc.ims_app.id
  vpc_endpoint_type = "Interface"
  subnet_ids = [aws_subnet.private_0.id, aws_subnet.private_1.id]
  security_group_ids = [aws_security_group.vpc_endpoint.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssmmessages" {
  service_name = "com.amazonaws.${var.region}.ssmmessages"
  vpc_id       = aws_vpc.ims_app.id
  vpc_endpoint_type = "Interface"
  subnet_ids = [aws_subnet.private_0.id, aws_subnet.private_1.id]
  security_group_ids = [aws_security_group.vpc_endpoint.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2messages" {
  service_name = "com.amazonaws.${var.region}.ec2messages"
  vpc_id       = aws_vpc.ims_app.id
  vpc_endpoint_type = "Interface"
  subnet_ids = [aws_subnet.private_0.id, aws_subnet.private_1.id]
  security_group_ids = [aws_security_group.vpc_endpoint.id]
  private_dns_enabled = true
}







##################NAT GATEWAY やっぱ要る（ログ送信 →さらにvpcエンドポイントに変更の為不要

# resource "aws_eip" "nat_gateway_0" {
#   depends_on = [aws_internet_gateway.ims_app]
# }
#
#resource "aws_eip" "nat_gateway_1" {
#  depends_on = [aws_internet_gateway.ims_app]
#}
#
#resource "aws_nat_gateway" "ims_app_0" {
#   allocation_id = aws_eip.nat_gateway_0.id
#   subnet_id     = aws_subnet.public_0.id
#   depends_on = [aws_internet_gateway.ims_app]
# }
#
#resource "aws_nat_gateway" "ims_app_1" {
#  allocation_id = aws_eip.nat_gateway_1.id
#  subnet_id     = aws_subnet.public_1.id
#  depends_on = [aws_internet_gateway.ims_app]
#}

###
