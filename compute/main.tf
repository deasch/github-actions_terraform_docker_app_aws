variable "repo_version"{
  default = "v0.0.0.1"
}


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}


# ========== PROVIDER
# ===== AWS
provider "aws" {
  region = "eu-central-1"
}


# ========== REPOSITORY
# ===== ECR
resource "aws_ecr_repository" "aws_sandbox_ecr" {
  name                 = "aws_sandbox_ecr"
  image_tag_mutability = "MUTABLE"

  tags = {
    Project     = "aws_sandbox"
    Name        = "aws_sandbox_ecr"
    Environment = "aws_sandbox"
  }
}
