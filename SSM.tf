resource "aws_ssm_parameter" "POSTGRES_USERNAME" {
  name = "/ims-app/POSTGRES_USERNAME"
  type = "String"
  value = "initialvalue"
  description = "username of db"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "POSTGRES_PASSWORD" {
  name = "/ims-app/POSTGRES_PASSWORD"
  type = "SecureString"
  value = "initialvalue"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "POSTGRES_DB" {
  name  = "/ims-app/POSTGRES_DB"
  type  = "String"
  value = "initialvalue"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "POSTGRES_ENDPOINT" {
  name  = "/ims-app/POSTGRES_ENDPOINT"
  type  = "String"
  value = "initialvalue"
  lifecycle {
    ignore_changes = [value]
  }
}


#########SSMによるパラメータ管理の場合(ENDPOINTはRDS作成後に実行すること
# aws ssm put-parameter --name '/ims-app/POSTGRES-DB' --type String　--value '変更したいParam' --overwrite
# aws ssm put-parameter --name '/ims-app/POSTGRES-PASSWORD' --type SecureString　--value '変更したいPass' --overwrite


