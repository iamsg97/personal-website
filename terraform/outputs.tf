output "alb_dns_name" {
  description = "ALB hostname. Point your domain's DNS record at this."
  value       = aws_lb.app.dns_name
}

output "site_url" {
  description = "Public HTTPS URL once DNS points at the ALB."
  value       = "https://${var.domain_name}"
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  value = aws_ecs_service.app.name
}

output "task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution.arn
}

output "github_actions_deploy_role_arn" {
  description = "Set this as the AWS_DEPLOY_ROLE_ARN GitHub Actions secret."
  value       = aws_iam_role.github_actions_deploy.arn
}

output "certificate_validation_records" {
  description = "Add each of these as a CNAME record at your DNS provider (Spaceship) to validate the ACM certificate."
  value = [
    for o in aws_acm_certificate.site.domain_validation_options : {
      name  = o.resource_record_name
      type  = o.resource_record_type
      value = o.resource_record_value
    }
  ]
}
