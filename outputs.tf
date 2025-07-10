# Get the NGINX LoadBalancer hostname after deployment
data "kubernetes_service" "nginx_ingress_controller" {
  count = var.install_nginx_ingress ? 1 : 0

  metadata {
    name      = "nginx-ingress-ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
  
  depends_on = [helm_release.nginx_ingress, time_sleep.wait_for_load_balancer]
}

output "ingress_load_balancer_hostname" {
  description = "NGINX Ingress LoadBalancer hostname"
  value       = var.install_nginx_ingress ? try(data.kubernetes_service.nginx_ingress_controller[0].status[0].load_balancer[0].ingress[0].hostname, "pending") : null
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
  value       = var.install_cert_manager && var.letsencrypt_email != "" ? "letsencrypt-prod" : null
}

output "letsencrypt_cluster_issuer_staging" {
  description = "Name of the staging Let's Encrypt ClusterIssuer"
  value       = var.install_cert_manager && var.letsencrypt_email != "" ? "letsencrypt-staging" : null
}