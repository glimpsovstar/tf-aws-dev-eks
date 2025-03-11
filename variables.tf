variable "aws_region" {
  description = "AWS region where the EKS cluster will be deployed"
  type        = string
  default     = "ap-southeast-2"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "vault-cluster"
}

variable "instance_type" {
  description = "Instance type for EKS nodes"
  type        = string
  default     = "t3.medium"
}
