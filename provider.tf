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
