resource "aws_s3_bucket" "ssm_operation_log" {
  bucket = "operation-ssm-log-202410xx"
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ims_app" {
  bucket = aws_s3_bucket.ssm_operation_log.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "ssm_operation"  {
  bucket = aws_s3_bucket.ssm_operation_log.id
  rule {
    id     = "operation"
    status = "Enabled"
    expiration {
      days = 180
    }
  }
}

resource "aws_s3_account_public_access_block" "private" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets  = true
}


resource "aws_s3_bucket" "alb_log" {
  bucket = "alb-log-202410xx"
  force_destroy = true
}

resource "aws_s3_bucket_lifecycle_configuration" "alb_log"  {
  bucket = aws_s3_bucket.alb_log.id
  rule {
    id     = "alb-log"
    status = "Enabled"
    expiration {
      days = 180
    }
  }
}


resource "aws_s3_bucket_policy" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id
  policy = data.aws_iam_policy_document.alb_log.json
}

data "aws_iam_policy_document" "alb_log" {
  statement {
    effect = "Allow"
    actions = ["s3:PutObject"]
    resources = ["arn:aws:s3:::alb-log-202410xx/*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::582318560864:root"]
    }
  }
}