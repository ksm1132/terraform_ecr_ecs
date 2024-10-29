#!/bin/sh
sudo dnf update -y > /tmp/user_data.log 2>&1
sudo dnf install postgresql16 -y >> /tmp/user_data.log 2>&1

DB_HOST=$(aws ssm get-parameter --name "/ims-app/POSTGRES_ENDPOINT" --with-decryption --query "Parameter.Value" --output text)
DB_NAME=$(aws ssm get-parameter --name "/ims-app/POSTGRES_DB" --with-decryption --query "Parameter.Value" --output text)
DB_USER=$(aws ssm get-parameter --name "/ims-app/POSTGRES_USERNAME" --with-decryption --query "Parameter.Value" --output text)
DB_PASSWORD=$(aws ssm get-parameter --name "/ims-app/POSTGRES_PASSWORD" --with-decryption --query "Parameter.Value" --output text)
S3_BUCKET="mkasatest"
SCHEMA_FILE="schema.sql"
DATA_FILE="data.sql"

export PGPASSWORD=$DB_PASSWORD

psql -h $DB_HOST -U $DB_USER -c "CREATE DATABASE $DB_NAME;" >> /tmp/user_data.log 2>&1

aws s3 cp s3://$S3_BUCKET/$SCHEMA_FILE $SCHEMA_FILE >> /tmp/user_data.log 2>&1
aws s3 cp s3://$S3_BUCKET/$DATA_FILE $DATA_FILE >> /tmp/user_data.log 2>&1

psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f $SCHEMA_FILE >> /tmp/user_data.log 2>&1
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f $DATA_FILE >> /tmp/user_data.log 2>&1

unset PGPASSWORD