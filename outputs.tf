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
  value       = var.route53_zone_name != "" ? data.aws_route53_zone.main[0].zone_id : null
}

output "route53_zone_name" {
  description = "Route53 main zone name"
  value       = var.route53_zone_name != "" ? data.aws_route53_zone.main[0].name : null
}

output "eks_subdomain_zone_id" {
  description = "EKS subdomain zone ID (if created)"
  value       = var.create_eks_subdomain_zone ? aws_route53_zone.eks_subdomain[0].zone_id : (var.route53_zone_name != "" ? data.aws_route53_zone.main[0].zone_id : null)
}

output "eks_subdomain_zone_name" {
  description = "EKS subdomain zone name"
  value       = var.create_eks_subdomain_zone ? aws_route53_zone.eks_subdomain[0].name : var.eks_subdomain_zone
}

output "eks_subdomain_name_servers" {
  description = "EKS subdomain name servers (if created)"
  value       = var.create_eks_subdomain_zone ? aws_route53_zone.eks_subdomain[0].name_servers : []
}

# SSL Infrastructure outputs
output "nginx_ingress_controller_installed" {
  description = "Whether NGINX ingress controller is installed"
  value       = var.install_nginx_ingress
}

output "cert_manager_installed" {
  description = "Whether cert-manager is installed"
  value       = var.install_cert_manager
}

output "letsencrypt_cluster_issuer_prod" {
  description = "Name of the production Let's Encrypt ClusterIssuer"
  value       = var.install_cert_manager ? "letsencrypt-prod" : null
}

output "letsencrypt_cluster_issuer_staging" {
  description = "Name of the staging Let's Encrypt ClusterIssuer"
  value       = var.install_cert_manager ? "letsencrypt-staging" : null
}

# Get the NGINX LoadBalancer hostname after deployment
data "kubernetes_service" "nginx_ingress_controller" {
  count = var.install_nginx_ingress ? 1 : 0

  metadata {
    name      = "nginx-ingress-ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
  
  depends_on = [helm_release.nginx_ingress]
}

output "ingress_load_balancer_hostname" {
  description = "NGINX Ingress LoadBalancer hostname"
  value       = var.install_nginx_ingress ? try(data.kubernetes_service.nginx_ingress_controller[0].status[0].load_balancer[0].ingress[0].hostname, "pending") : null
}
