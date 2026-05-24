# AWSプロバイダ設定
provider "aws" {
  profile = "default"
  region  = var.aws_region
}

provider "aws" {
  alias   = "us_east_1"
  profile = "default"
  region  = "us-east-1"
}
