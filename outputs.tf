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

output "vpc_id" {
  description = "VPC ID"
  value       = data.terraform_remote_state.aws_dev_vpc.outputs.vpc_id
}

output "subnet_ids" {
  description = "Subnets used by the EKS cluster"
  value       = data.terraform_remote_state.aws_dev_vpc.outputs.subnet_ids
}
