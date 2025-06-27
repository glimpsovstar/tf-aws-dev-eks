output "eks_cluster_name" {
  description = "EKS Cluster name"
  value       = module.eks.cluster_name
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
  value       = data.terraform_remote_state.aws_dev_vpc.outputs.vpc_private_subnets
}

output "eks_iam_role_name" {
  description = "The IAM role used by EKS cluster"
  value       = module.eks.cluster_iam_role_name
}


# Route53 outputs for consumption by application layers
output "route53_zone_id" {
  description = "Route53 main zone ID"
  value       = data.aws_route53_zone.main.zone_id
}

output "route53_zone_name" {
  description = "Route53 main zone name"
  value       = data.aws_route53_zone.main.name
}

output "eks_subdomain_zone_id" {
  description = "EKS subdomain zone ID (if created)"
  value       = var.create_eks_subdomain_zone ? aws_route53_zone.eks_subdomain[0].zone_id : data.aws_route53_zone.main.zone_id
}

output "eks_subdomain_zone_name" {
  description = "EKS subdomain zone name"
  value       = var.create_eks_subdomain_zone ? aws_route53_zone.eks_subdomain[0].name : var.eks_subdomain_zone
}

output "eks_subdomain_name_servers" {
  description = "EKS subdomain name servers (if created)"
  value       = var.create_eks_subdomain_zone ? aws_route53_zone.eks_subdomain[0].name_servers : []
}