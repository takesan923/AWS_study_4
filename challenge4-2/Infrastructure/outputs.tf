output "cloudfront_domain" {
  value = aws_cloudfront_distribution.api.domain_name
}

output "alb_dns" {
  value = aws_lb.main.dns_name
}

output "bastion_instance_id" {
  value = aws_instance.bastion.id
}

output "api_instance_id" {
  value = aws_instance.api.id
}

output "rds_endpoint" {
  value = aws_db_instance.main.address
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions_deploy.arn
}
