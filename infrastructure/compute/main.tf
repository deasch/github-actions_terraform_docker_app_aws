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


# ========== COMPUTE - REPOSITORY
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


# ===== DATA SOURCE NETWORKING
data "aws_security_group" "aws_sandbox_default_sg" {
  filter {
    name   = "tag:Name"
    values = ["aws_sandbox_default_sg"]
  }
}
data "aws_vpc" "aws_sandbox_vpc" {
  filter {
    name   = "tag:Name"
    values = ["aws_sandbox_vpc"]
  }
}
data "aws_subnet" "aws_sandbox_public_subnet" {
  vpc_id = data.aws_vpc.aws_sandbox_vpc.id
  filter {
    name   = "tag:Name"
    values = ["aws_sandbox_eu-central-1a_public_subnet"]
  }
}
data "aws_subnet" "aws_sandbox_private_subnet" {
  vpc_id = data.aws_vpc.aws_sandbox_vpc.id
  filter {
    name   = "tag:Name"
    values = ["aws_sandbox_eu-central-1a_private_subnet"]
  }
}


# ========== COMPUTE - INSTANCES
# ===== EC2 - APP Server
resource "aws_instance" "aws_sandbox_webserver" {
  count         = 1 
  ami           = "ami-0b2ac948e23c57071"
  instance_type = "t2.micro"
  
  key_name      = "devops_sandbox_aws"
  subnet_id     = data.aws_subnet.aws_sandbox_public_subnet[0].id
  vpc_security_group_ids = [data.aws_security_group.aws_sandbox_default_sg.id]

  tags = {
    Project     = "aws_sandbox"
    Name        = "aws_sandbox_webserver"
    Environment = "aws_sandbox"
  }
}
