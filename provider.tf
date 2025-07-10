terraform {
  cloud {
    organization = "djoo-hashicorp"
    workspaces {
      name = "tf-aws-dev-eks"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}