terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

terraform {
  cloud {
    organization = "djoo-hashicorp"
    workspaces {
      name = "tf-aws-dev-eks"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "aws" {
  region = var.aws_region
}

