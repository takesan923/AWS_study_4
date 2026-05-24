variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-northeast-1"
}

variable "db_root_pass" {
  description = "RDS password"
  type        = string
  sensitive   = true
}
