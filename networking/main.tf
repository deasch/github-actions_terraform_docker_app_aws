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
# ===== DEFAULT SECURITY GROUP
resource "aws_security_group" "aws_sandbox_default_sg" {
  name        = "aws_sandbox_default_sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = aws_vpc.aws_sandbox_vpc.id
  depends_on  = [aws_vpc.aws_sandbox_vpc]
  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }
  
  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }
  tags = {
    Environment = "aws_sandbox"
  }
}


# ========== NETWORKING - SUBNETS
# ===== PUBLIC SUBNET
resource "aws_subnet" "aws_sandbox_public_subnet" {
  vpc_id                  = aws_vpc.aws_sandbox_vpc.id
  count                   = 1
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true
  tags = {
    Name        = "aws_sandbox_eu-central-1a_public_subnet"
    Environment = "aws_sandbox"
  }
}
# ===== PRIVATE SUBNET
resource "aws_subnet" "aws_sandbox_private_subnet" {
  vpc_id                  = aws_vpc.aws_sandbox_vpc.id
  count                   = 1
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = false
  tags = {
    Name        = "aws_sandbox_eu-central-1a_private_subnet"
    Environment = "aws_sandbox"
  }
}


# ========== NETWORKING - GATEWAYS
# ===== INTERNET GATEWAY
resource "aws_internet_gateway" "aws_sandbox_igw" {
  vpc_id = aws_vpc.aws_sandbox_vpc.id
  tags = {
    Name        = "aws_sandbox_igw"
    Environment = "aws_sandbox"
  }
}
# ===== ElASTIC IP FOR NAT GATEWAY
resource "aws_eip" "aws_sandbox_nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.aws_sandbox_igw]
}
# ===== NAT GATEWAY
resource "aws_nat_gateway" "aws_sandbox_nat" {
  allocation_id = aws_eip.aws_sandbox_nat_eip.id
  subnet_id     = aws_subnet.aws_sandbox_public_subnet[1].id
  depends_on    = [aws_internet_gateway.aws_sandbox_igw]
  tags = {
    Name        = "aws_sandbox_nat"
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
# ===== ROUTING - PUBLIC INTERNET GATEWAY
resource "aws_route" "aws_sandbox_public_internet_gateway" {
  route_table_id         = aws_route_table.aws_sandbox_public_routetable.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.aws_sandbox_igw.id
}
# ===== ROUTING - PRIVATE INTERNET GATEWAY
resource "aws_route" "aws_sandbox_private_nat_gateway" {
  route_table_id         = aws_route_table.aws_sandbox_private_routetable.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.aws_sandbox_nat.id
}
# ===== PUBLIC ROUTE TABLE ASSOCIATION
resource "aws_route_table_association" "public" {
  count          = 1
  subnet_id      = aws_subnet.aws_sandbox_public_subnet[1].id
  route_table_id = aws_route_table.aws_sandbox_public_routetable.id
}
# ===== PRIVATE ROUTE TABLE ASSOCIATION
resource "aws_route_table_association" "private" {
  count          = 1
  subnet_id      = aws_subnet.aws_sandbox_private_subnet[1].id
  route_table_id = aws_route_table.aws_sandbox_private_routetable.id
}







