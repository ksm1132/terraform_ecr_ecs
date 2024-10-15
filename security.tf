resource "aws_security_group" "ims_app" {
  name = "ims-app"
  vpc_id = aws_vpc.ims_app.id
}

resource "aws_security_group_rule" "ingress_ims_app" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.ims_app.id
  to_port           = 80
  type              = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "egress_ims_app" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.ims_app.id
  to_port           = 0
  type              = "egress"
  cidr_blocks = ["0.0.0.0/0"]
}