variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Short name used to prefix/tag all resources."
  type        = string
  default     = "suvadeep-portfolio"
}

variable "github_repository" {
  description = "GitHub \"owner/repo\" allowed to assume the deploy role via OIDC."
  type        = string
  default     = "iamsg97/personal-website"
}

variable "instance_type" {
  description = "EC2 instance type backing the ECS cluster."
  type        = string
  default     = "t3.micro"
}

variable "container_port" {
  description = "Port the Next.js server listens on inside the container."
  type        = number
  default     = 3000
}

variable "desired_count" {
  description = "Number of ECS tasks to run."
  type        = number
  default     = 1
}

variable "container_cpu" {
  description = "CPU units reserved for the container (out of 1024 per vCPU)."
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Hard memory limit (MiB) for the container. t3.micro has 1 GiB total."
  type        = number
  default     = 400
}

variable "domain_name" {
  description = "Custom domain the site is served on (DNS managed externally at Spaceship, not Route 53)."
  type        = string
  default     = "suvadeepghoshal.dev"
}

variable "contact_to_email" {
  description = "Address contact-form submissions are delivered to."
  type        = string
  default     = "ghoshalsuvadeep594@gmail.com"
}

variable "contact_from_email" {
  description = "Verified Resend sender address."
  type        = string
  default     = "onboarding@resend.dev"
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention for container logs."
  type        = number
  default     = 14
}
