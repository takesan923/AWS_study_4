# 1. SSM でポートフォワード（別ターミナルで起動したまま）

```
aws ssm start-session \
--target $(cd challenge1 && terraform output -raw bastion_instance_id) \
--document-name AWS-StartPortForwardingSessionToRemoteHost \
--parameters "host=$(cd challenge1 && terraform output -raw rds_endpoint),portNumber=3306,localPortNumber=13306"
```

# 2. Migration 実行（challenge1/ で）

```
DB_HOST=127.0.0.1 DB_PORT=13306 DB_USER=app_user \
DB_PASSWORD=<********************> DB_NAME=app_db \
alembic upgrade head
```
