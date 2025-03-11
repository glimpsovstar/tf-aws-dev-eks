output "eks_cluster_id" {
  description = "EKS Cluster ID"
  value       = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
  description = "EKS Cluster API Endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_certificate_authority" {
  description = "EKS Certificate Authority Data"
  value       = module.eks.cluster_certificate_authority_data
}

output "subnet_ids" {
  description = "List of subnet IDs"
  value       = module.eks.subnet_ids
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.eks.vpc_id
}

