resource "aws_db_parameter_group" "ims_app" {
  family = "postgres16"  # PostgreSQLのバージョンに応じたファミリー名
  name   = "ims-db"

  parameter {
    name  = "client_encoding"
    value = "UTF8"
  }

  parameter {
    name  = "timezone"
    value = "UTC"
  }
}
############option groupはPostgresに存在しない
# resource "aws_db_option_group" "ims_app" {
#   engine_name          = "postgres"
#   major_engine_version = "14"
#   name                 = "ims-db"
#
#   option {
#     option_name = "Timezone"
#   }
# }

resource "aws_db_subnet_group" "ims_app" {
  subnet_ids = [aws_subnet.private_0.id, aws_subnet.private_1.id]
  name       = "ims-db"
}

data "aws_ssm_parameter" "POSTGRES_USERNAME" {
  name = "/ims-app/POSTGRES_USERNAME"
  with_decryption = true
}

data "aws_ssm_parameter" "POSTGRES_PASSWORD" {
  name = "/ims-app/POSTGRES_PASSWORD"
  with_decryption = true
}

resource "aws_db_instance" "ims_app" {
  instance_class          = "db.t4g.micro"
  identifier              = "ims-app"
  engine                 = "postgres"
  engine_version         = "16.1"  # PostgreSQLのバージョンに変更
  allocated_storage       = 20
  max_allocated_storage   = 100
  storage_type           = "gp3"
  storage_encrypted      = true
  kms_key_id             = aws_kms_key.ims_app.arn
  username               = data.aws_ssm_parameter.POSTGRES_USERNAME.value
  password               = data.aws_ssm_parameter.POSTGRES_PASSWORD.value
  multi_az               = true
  publicly_accessible     = false
  backup_window          = "09:10-09:40"
  backup_retention_period = 30
  maintenance_window     = "mon:10:10-mon:10:40"
  auto_minor_version_upgrade = false
  deletion_protection    = false
  skip_final_snapshot    = true
  port                   = 5432
  apply_immediately      = false
  vpc_security_group_ids = [module.postgres_sg.security_group_id]
  parameter_group_name   = aws_db_parameter_group.ims_app.name
#   option_group_name      = aws_db_option_group.ims_app.name
  db_subnet_group_name   = aws_db_subnet_group.ims_app.name

  lifecycle {
    ignore_changes = [password]
  }
}

##################RDS.tfはapply除外してSSMの登録完了後にRDS.tfのApplyを実施
#########直接RDS上で変更の場合
# aws rds modify-db-instance --db-instance-identifier 'ims-app' --master-user-password '変更したいパスワード'

#########SSMによるパラメータ管理の場合
# aws ssm put-parameter --name '/ims-app/POSTGRES-PASSWORD' --type SecureString　--value '変更したいPass' --overwrite