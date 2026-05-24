#!/bin/bash
set -e

dnf install -y docker
systemctl enable docker
systemctl start docker

mkdir -p /app

DB_PASSWORD=$(aws secretsmanager get-secret-value \
--secret-id "${secret_arn}" \
--query SecretString \
--output text \
--region "${aws_region}")

cat > /app/.env <<EOF
DB_HOST=${db_host}
DB_PORT=3306
DB_NAME=app_db
DB_USER=app_user
DB_PASSWORD=$DB_PASSWORD
EOF
chmod 600 /app/.env