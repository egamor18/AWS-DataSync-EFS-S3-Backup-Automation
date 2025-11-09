
terraform {
  required_version = ">= 1.5"
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



data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "web" {
  count                       = var.number_of_ec2s
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = data.terraform_remote_state.infra.outputs.public_subnets[count.index]
  vpc_security_group_ids      = [data.terraform_remote_state.infra.outputs.security_group_id]
  associate_public_ip_address = true
  tags                        = { Name = "web-${count.index + 1}" }

  user_data = templatefile(
    var.ec2_user_data, {
      efs_id = data.terraform_remote_state.infra.outputs.efs_id
    }

  )
}
