terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Reference pre-provisioned infrastructure
data "terraform_remote_state" "infra" {
  backend = "local"
  config = {
    path = "../1.permanent_infra/terraform.tfstate"
  }
}