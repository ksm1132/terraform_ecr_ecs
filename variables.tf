variable "aws_account_id" {
  description = "AWS Account ID"
  default = "888577050419"
}

variable "region" {
  description = "AWS Region"
  default     = "ap-northeast-1"
}

variable "repository_name" {
  description = "ECR Repository Name"
}

variable "tag" {
  description = "Image Tag"
  default     = "latest"
}

variable "POSTGRES_DB" {
  description = "DB Name of the postgres"
}

variable "POSTGRES_USERNAME" {
  description = "DB USERNAME of the postgres"
}

variable "POSTGRES_PASSWORD" {
  description = "DB PASSWORD of the postgres"
}
