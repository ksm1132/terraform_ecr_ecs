data "aws_iam_policy_document" "allow_describe_regions" {
  statement {
    effect = "Allow"
    actions = ["ec2:DescribeRegions"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ims_app_ec2" {
  name = "ims_app_ec2"
  policy = data.aws_iam_policy_document.allow_describe_regions.json
}

module "describe_regions_for_ec2" {
  source = "./iam_role"
  name = "describe-regions-for-ec2"
  identifier = "ec2.amazonaws.com"
  policy = data.aws_iam_policy_document.allow_describe_regions.json
}

module "ims_app_sg" {
  source = "./security_group"
  name = "ims-app-sg"
  vpc_id = aws_vpc.ims_app.id
  port = 80
  cidr_blocks = ["0.0.0.0/0"]
}