resource "aws_ssm_parameter" "POSTGRES_USERNAME" {
  name = "/ims-app/POSTGRES-USERNAME"
  type = "String"
  value = "initialvalue"
  description = "username of db"
}

resource "aws_ssm_parameter" "POSTGRES_PASSWORD" {
  name = "/ims-app/POSTGRES-PASSWORD"
  type = "SecureString"
  value = "initialvalue"
}

resource "aws_ssm_parameter" "POSTGRES_DB" {
  name  = "/ims-app/POSTGRES-DB"
  type  = "String"
  value = "initialvalue"
}

