terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70.0"  # 使用したい最新のバージョンに更新
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}
