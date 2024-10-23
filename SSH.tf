data "aws_iam_policy_document" "ec2_for_ssm" {
  source_policy_documents = [data.aws_iam_policy.ec2_for_ssm.policy]

  statement {
    effect = "Allow"
    resources = ["*"]

    actions = [
      "s3:PutObject",
      "s3:GetObject",               // 追加
      "s3:ListBucket",              // 追加
      "s3:ListAllMyBuckets",        // 追加
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
      "kms:Decrypt",
    ]
  }
}

data "aws_iam_policy" "ec2_for_ssm" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

module "ec2_for_ssm_role" {
  source = "./iam_role"
  name = "ec2-for-ssm"
  identifier = "ec2.amazonaws.com"
  policy = data.aws_iam_policy_document.ec2_for_ssm.json
}

resource "aws_iam_instance_profile" "ec2_for_ssm" {
  name = "ec2-for-ssm"
  role = module.ec2_for_ssm_role.iam_role_name
}

resource "aws_instance" "ims_app_for_operation" {
  ami = "ami-03f584e50b2d32776"
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2_for_ssm.name
  subnet_id = aws_subnet.private_0.id
  security_groups = [module.https_sg.security_group_id]
  user_data = "file(./user_data.sh)"
}

output "operation_instance_id" {
  value = aws_instance.ims_app_for_operation.id
}

resource "aws_cloudwatch_log_group" "ssm_operation" {
  name = "/operation"
  retention_in_days = 180
}

resource "aws_ssm_document" "session_manager_run_shell" {
  content       = <<EOF
    {
    "schemaVersion": "1.0",
    "description": "Document to hold regional settings for Session Manager",
    "sessionType": "Standard_Stream",
    "inputs": {
      "s3BucketName": "${aws_s3_bucket.ssm_operation_log.id}",
      "cloudWatchLogGroupName": "${aws_cloudwatch_log_group.ssm_operation.name}"
    }
  }
EOF
  document_type = "Session"
  name          = "SSM-SessionManagerRunShell"
  document_format = "JSON"
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  policy_arn = data.aws_iam_policy.ec2_for_ssm.arn
  role       = module.ec2_for_ssm_role.iam_role_name
}