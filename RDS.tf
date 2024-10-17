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

# resource "aws_db_option_group" "ims_app" {
#   engine_name          = "postgres"
#   major_engine_version = "14"  # PostgreSQLのメジャーバージョンに変更
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

resource "aws_db_instance" "ims_app" {
  instance_class          = "db.t3.small"
  identifier              = "ims-app"
  engine                 = "postgres"
  engine_version         = "16.1"  # PostgreSQLのバージョンに変更
  allocated_storage       = 20
  max_allocated_storage   = 100
  storage_type           = "gp3"
  storage_encrypted      = true
#   kms_key_id             = aws_kms_key.ims_app.arn
  username               = "postgres"
  password               = "1234Abcd"
  multi_az               = true
  publicly_accessible     = false
  backup_window          = "09:10-09:40"
  backup_retention_period = 30
  maintenance_window     = "mon:10:10-mon:10:40"
  auto_minor_version_upgrade = false
  deletion_protection    = false
  skip_final_snapshot    = true
  port                   = 5432  # PostgreSQLのデフォルトポート
  apply_immediately      = false
  vpc_security_group_ids = [module.ims_app_sg.security_group_id]
  parameter_group_name   = aws_db_parameter_group.ims_app.name
#   option_group_name      = aws_db_option_group.ims_app.name
  db_subnet_group_name   = aws_db_subnet_group.ims_app.name

  lifecycle {
    ignore_changes = [password]
  }
}

# aws rds modify-db-instance --db-instance-identifier 'ims-app' --master-user-password '変更したいパスワード'