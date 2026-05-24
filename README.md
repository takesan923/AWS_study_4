# AWS_study

AWSの基礎構築を学ぶ

## フォルダ構成

```
AWS_study/
├── .gitignore
├── .terraform.lock.hcl
├── README.md
├── case1/                      # 構成1: EC2単体
│   ├── .terraform.lock.hcl
│   ├── main.tf
│   ├── outputs.tf
│   ├── terraform.tf
│   └── variables.tf
├── case2/                      # 構成2: EC2 + RDS + ALB + CloudFront
│   ├── .terraform.lock.hcl
│   ├── main.tf
│   ├── outputs.tf
│   ├── terraform.tf
│   └── variables.tf
└── case3/                      # 構成3: ECS + RDS + ALB + CloudFront
    ├── .terraform.lock.hcl
    ├── main.tf
    ├── outputs.tf
    ├── terraform.tf
    └── variables.tf
```

```
challenge1:
  challenge1/
  ├── app/
  │   ├── router/
  │   │   ├── __init__.py
  │   │   └── tasks.py
  │   ├── database.py
  │   ├── main.py
  │   ├── models.py
  │   └── schemas.py
  ├── alembic/
  │   └── env.py
  ├── Dockerfile
  ├── requirements.txt
  ├── alb.tf
  ├── bastion.tf
  ├── cloudfront.tf
  ├── ecr.tf
  ├── ecs.tf
  ├── event_bridge.tf
  ├── github_actions_iam.tf
  ├── iam.tf
  ├── lambda.tf
  ├── main.tf
  ├── network.tf
  ├── outputs.tf
  ├── rds.tf
  ├── secrets.tf
  ├── security_groups.tf
  ├── stepfunction.tf
  ├── terraform.tf
  └── variables.tf

  challenge3:
  challenge3/
  ├── Backend/
  │   ├── app/
  │   │   ├── router/
  │   │   │   ├── __init__.py
  │   │   │   └── tasks.py
  │   │   ├── database.py
  │   │   ├── image_utils.py
  │   │   ├── main.py
  │   │   ├── models.py
  │   │   └── schemas.py
  │   ├── Dockerfile
  │   └── requirements.txt
  ├── Frontend/
  │   ├── src/
  │   │   ├── api/
  │   │   │   └── tasks.ts
  │   │   ├── assets/
  │   │   ├── components/
  │   │   │   ├── taskcard.tsx
  │   │   │   ├── taskform.tsx
  │   │   │   └── tasklist.tsx
  │   │   ├── types/
  │   │   │   └── task.ts
  │   │   ├── App.tsx
  │   │   └── main.tsx
  │   ├── public/
  │   ├── .dockerignore
  │   ├── Dockerfile
  │   └── nginx.conf
  └── Infrastructure/
      ├── alb.tf
      ├── bastion.tf
      ├── cloudfront.tf
      ├── ecr.tf
      ├── ecs.tf
      ├── event_bridge.tf
      ├── github_actions_iam.tf
      ├── iam.tf
      ├── lambda.tf
      ├── main.tf
      ├── network.tf
      ├── outputs.tf
      ├── rds.tf
      ├── s3.tf
      ├── secrets.tf
      ├── security_groups.tf
      ├── stepfunction.tf
      ├── terraform.tf
      ├── variables.tf
      └── waf.tf
```

## 構成一覧

### 構成1 — EC2単体（WordPress + MySQL 同居）

単一のEC2インスタンス上にWordPressとMySQLを同居させたシンプルな構成

- **EC2**: WordPress + MySQL（MariaDB）をインストール

### 構成2 — EC2 + RDS + ALB + CloudFront

DBをRDSに分離し、ALBによる負荷分散とCloudFrontによるキャッシュ配信を追加した構成

- **EC2**: WordPressのみ
- **RDS**: マネージドMySQL
- **ALB**: 複数EC2へのトラフィック分散
- **CloudFront**: 静的コンテンツのキャッシュ配信

### 構成3 — ECS + RDS + ALB + CloudFront

コンテナ化によりインフラ管理をさらに省力化した構成

- **ECS（Fargate）**: コンテナ化されたWordPressを実行
- **RDS**: マネージドMySQL
- **ALB**: コンテナへのトラフィック分散
- **CloudFront**: 静的コンテンツのキャッシュ配信

---

## 課題

### 課題1 — ECS + FastAPI REST API

ECS(Fargate) + RDS + ALB + CloudFront 構成でタスク管理 REST API を実装

- **ECS（Fargate）**: FastAPI アプリをコンテナで実行
- **RDS**: MySQL によるタスクデータの永続化
- **ALB**: ECS へのトラフィック分散
- **CloudFront**: API へのキャッシュなし配信
- **EC2踏み台**: RDS への安全なアクセス・マイグレーション実行

### 課題3 — フルスタック構成

タスク管理アプリをフロントエンドからインフラまで一貫して構築

#### アーキテクチャ

```
CloudFront
├── /images/_ → S3（OAC・署名付きURL）
└── /_ → ALB
├── /api/_ → ECS API（FastAPI）
└── /_ → ECS Frontend（React/Vite）
```

#### 使用サービス

| サービス        | 役割                                            |
| --------------- | ----------------------------------------------- |
| CloudFront      | CDN・S3へのOACアクセス・Signed URL              |
| ALB             | パスベースルーティング（API / Frontend）        |
| ECS Fargate     | API（FastAPI）・Frontend（React）をコンテナ実行 |
| ECR             | コンテナイメージの管理                          |
| RDS (MySQL)     | タスクデータの永続化                            |
| S3              | 画像のセキュア保存（SSE-S3暗号化）              |
| WAF             | メンテナンスモード（503カスタムレスポンス）     |
| EventBridge     | タスク作成イベントの配信                        |
| Step Functions  | Slack通知のワークフロー制御                     |
| Lambda          | Slack Webhook 通知                              |
| Secrets Manager | DB・CloudFront秘密鍵の管理                      |
| EC2踏み台       | RDS へのマイグレーション実行                    |

#### 画像フロー

アップロード

Frontend → POST /api/tasks/{id}/image/upload-url
→ S3 Presigned URL 発行
→ Frontend が S3 に直接 PUT（暗号化保存）
→ PUT /api/tasks/{id} で picture_key を保存

閲覧

GET /api/tasks/{id}
→ picture_url に CloudFront Signed URL を生成して返却
→ Frontend → CloudFront → OAC → S3

#### CI/CD

- `challenge3/Backend/**` または `challenge3/Frontend/**` への push で自動デプロイ
- API・Frontend を並列ビルド → ECR push → ECS タスク定義更新
- WAF メンテナンスモードは GitHub Actions の `workflow_dispatch` で ON/OFF
