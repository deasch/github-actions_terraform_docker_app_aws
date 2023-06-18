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


# ========== MODULES
# === NETWORKING
module "networking" {
  source = "./modules/networking"
}
# === COMPUTE
module "compute" {
  source = "./modules/compute"
}
