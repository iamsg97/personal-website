terraform {
  required_version = ">= 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70"
    }
  }

  # Local state by default so this stack can be applied with zero pre-existing
  # AWS resources. For a real team setup, switch to an S3 backend (see
  # docs/AWS_HOSTING.md) so state is shared and locked.
  # backend "s3" {}
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = var.project_name
      ManagedBy = "terraform"
    }
  }
}
