resource "aws_ssm_parameter" "POSTGRES_USERNAME" {
  name = "/ims-app/POSTGRES_USERNAME"
  type  = "String"
  value = "initialValue"
  description = "username of posgresSQL"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "POSTGRES_PASSWORD" {
  name = "/ims-app/POSTGRES_PASSWORD"
  type  = "SecureString"
  value = "initialValue"
  description = "password of posgresSQL"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "POSTGRES_DB" {
  name = "/ims-app/POSTGRES_DB"
  type  = "String"
  value = "initialValue"
  description = "db name of posgresSQL"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "POSTGRES_ENDPOINT" {
  name = "/ims-app/POSTGRES_ENDPOINT"
  type  = "SecureString"
  value = "initialValue"
  description = "endpoint of posgresSQL"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "GOOGLE_CLIENT_ID" {
  name = "/ims-app/GOOGLE_CLIENT_ID"
  type  = "SecureString"
  value = "initialValue"
  description = "GOOGLE CLIENT ID"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "GOOGLE_CLIENT_SECRET" {
  name = "/ims-app/GOOGLE_CLIENT_SECRET"
  type  = "SecureString"
  value = "initialValue"
  description = "GOOGLE CLIENT SECRET"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "myappDomain" {
  name = "/ims-app/myappDomain"
  type  = "String"
  value = "initialValue"
  description = "Domain name"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "EMAIL_ADDRESS" {
  name = "/ims-app/EMAIL_ADDRESS"
  type  = "SecureString"
  value = "initialValue"
  description = "SMTP server"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "EMAIL_PASSWORD" {
  name = "/ims-app/EMAIL_PASSWORD"
  type  = "SecureString"
  value = "initialValue"
  description = "Password of SMTP server"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "ECR_REPO" {
  name = "/ims-app/ECR_REPO"
  type  = "String"
  value = "initialValue"
  description = "repository name of ECR"
  lifecycle {
    ignore_changes = [value]
  }
}

