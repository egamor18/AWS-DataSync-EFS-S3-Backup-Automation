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
  region = "eu-central-1"
}

##########################
# VPC CONFIGURATION
##########################
# Using the official AWS VPC module to create a simple VPC with two public subnets
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.5.0"

  name = "ec2-efs-s3-archiving-vpc"
  cidr = "10.0.0.0/16"

  azs            = ["eu-central-1a", "eu-central-1b"]
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

  enable_nat_gateway      = false
  single_nat_gateway      = false
  enable_dns_hostnames    = true
  enable_dns_support      = true
  
  map_public_ip_on_launch = true
}


##########################
# SECURITY GROUP
##########################
# Allows SSH and NFS traffic between EC2 instances and EFS
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  description = "Allow SSH, HTTPS and NFS"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH access from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # we make this more restrictive later
  }

  ingress {
    description = "NFS access within the VPC"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

ingress {
    description = "HTTPS access within the VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



##########################
# EFS FILE SYSTEM
##########################
# Used to share data between EC2 instances
resource "aws_efs_file_system" "web_data" {
  creation_token = "web-efs"

  # Automatically transition files to Infrequent Access (IA) after 30 days
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name = "web-efs"
  }
}

# Mount targets in both Availability Zones
# Each mount target provides a local, AZ-specific endpoint for the EFS filesystem.
# EC2s in the same AZ use their local mount target to access EFS over a private IP,
# avoiding cross-AZ network traffic and reducing latency.
# This is conceptually similar to an S3 VPC gateway endpoint.

resource "aws_efs_mount_target" "efs_a" {
  file_system_id  = aws_efs_file_system.web_data.id
  subnet_id       = module.vpc.public_subnets[0]
  security_groups = [aws_security_group.ec2_sg.id]
}

# Second mount target for the other AZ.
# Ensures EC2s in AZ 2 can access the same EFS filesystem locally.

resource "aws_efs_mount_target" "efs_b" {
  file_system_id  = aws_efs_file_system.web_data.id
  subnet_id       = module.vpc.public_subnets[1]
  security_groups = [aws_security_group.ec2_sg.id]
}

