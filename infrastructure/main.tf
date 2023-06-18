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


# ========== NETWORKING - VPC
# ===== VPC
resource "aws_vpc" "aws_sandbox_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "aws_sandbox_vpc"
    Environment = "aws_sandbox"
  }
}


# ========== NETWORKING - SUBNETS
# ===== PUBLIC SUBNET
resource "aws_subnet" "aws_sandbox_public_subnet" {
  vpc_id                  = aws_vpc.aws_sandbox_vpc.id
  count                   = "${length(var.public_subnets_cidr)}"
  cidr_block              = "${element(var.public_subnets_cidr,   count.index)}"
  availability_zone       = "${element(var.availability_zones,   count.index)}"
  map_public_ip_on_launch = true
  tags = {
    Name        = "aws_sandbox-${element(var.availability_zones, count.index)}-public-subnet"
    Environment = "aws_sandbox"
  }
}
# ===== PRIVATE SUBNET
resource "aws_subnet" "aws_sandbox_private_subnet" {
  vpc_id                  = aws_vpc.aws_sandbox_vpc.id
  count                   = "${length(var.private_subnets_cidr)}"
  cidr_block              = "${element(var.private_subnets_cidr, count.index)}"
  availability_zone       = "${element(var.availability_zones,   count.index)}"
  map_public_ip_on_launch = false
  tags = {
    Name        = "aws_sandbox-${element(var.availability_zones, count.index)}-private-subnet"
    Environment = "aws_sandbox"
  }
}


# ========== NETWORKING - ROUTING TABLES
# ===== PUBLIC ROUTE TABLE
resource "aws_route_table" "aws_sandbox_public_routetable" {
  vpc_id = aws_vpc.aws_sandbox_vpc.id
  tags = {
    Name        = "aws_sandbox-public-route-table"
    Environment = "aws_sandbox"
  }
}
# ===== PRIVATE ROUTE TABLE
resource "aws_route_table" "aws_sandbox_private_routetable" {
  vpc_id = aws_vpc.aws_sandbox_vpc.id
  tags = {
    Name        = "aws_sandbox-private-route-table"
    Environment = "aws_sandbox"
  }
}






