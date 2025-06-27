variable "aws_region" {
  description = "AWS region where the EKS cluster will be deployed"
  type        = string
  default     = "ap-southeast-2"
}

variable "eks_cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "vault-demo-cluster"
}

variable "instance_type" {
  description = "Instance type for EKS nodes"
  type        = string
  default     = "t3.medium"
}

variable "eks_cluster_version" {
  description = "The Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.32"
}

variable "vault_domain_name" {
  description = "The domain name for the Vault service"
  type        = string
  default     = "vault-poc.withdevo.dev"
}


# Route53 Configuration
variable "route53_zone_name" {
  description = "The main Route53 hosted zone name"
  type        = string
  default     = "david-joo.sbx.hashidemos.io"
}

variable "eks_subdomain_zone" {
  description = "The EKS subdomain zone name"
  type        = string
  default     = "eks.david-joo.sbx.hashidemos.io"
}

variable "create_eks_subdomain_zone" {
  description = "Whether to create a separate hosted zone for EKS subdomain"
  type        = bool
  default     = false
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}