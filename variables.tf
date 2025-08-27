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
  default     = "1.30"  # Fixed: Valid Kubernetes version (was 1.33)
}

# Route53 Configuration
variable "route53_zone_name" {
  description = "The main Route53 hosted zone name"
  type        = string
  default     = ""
}

variable "eks_subdomain_zone" {
  description = "The EKS subdomain zone name"
  type        = string
  default     = ""
}

variable "create_eks_subdomain_zone" {
  description = "Whether to create a separate hosted zone for EKS subdomain"
  type        = bool
  default     = false
}

# DNS Configuration (static only - no LoadBalancer dependencies)
variable "static_dns_records" {
  description = "Static DNS records that don't depend on LoadBalancer"
  type = map(object({
    type    = string
    ttl     = number
    records = list(string)
  }))
  default = {}
  # Example:
  # static_dns_records = {
  #   "mail.yourdomain.com" = {
  #     type    = "MX"
  #     ttl     = 300
  #     records = ["10 mail.provider.com"]
  #   }
  # }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# Add-on installation variables
variable "install_nginx_ingress" {
  description = "Whether to install NGINX Ingress Controller"
  type        = bool
  default     = false
}

variable "install_cert_manager" {
  description = "Whether to install cert-manager"
  type        = bool
  default     = false
}