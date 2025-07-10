# Create namespace first
resource "kubernetes_namespace" "ingress_nginx" {
  count    = var.install_nginx_ingress ? 1 : 0
  provider = kubernetes.eks
  
  metadata {
    name = "ingress-nginx"
    labels = {
      name = "ingress-nginx"
    }
  }
  
  depends_on = [module.eks]
}

# Wait for namespace to be ready
resource "time_sleep" "wait_for_namespace" {
  count = var.install_nginx_ingress ? 1 : 0
  
  depends_on = [kubernetes_namespace.ingress_nginx]
  create_duration = "30s"
}

# Install NGINX Ingress Controller
resource "helm_release" "nginx_ingress" {
  count            = var.install_nginx_ingress ? 1 : 0
  provider         = helm.eks
  name             = "nginx-ingress"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.8.3"
  namespace        = "ingress-nginx"
  create_namespace = false  # Already created above
  timeout          = 900    # 15 minutes
  wait             = false  # Don't wait to avoid timeout during LB provisioning
  
  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
    value = "internet-facing"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-cross-zone-load-balancing-enabled"
    value = "true"
  }

  # Add health check settings for faster LB provisioning
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-healthcheck-protocol"
    value = "HTTP"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-healthcheck-port"
    value = "10254"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-healthcheck-path"
    value = "/healthz"
  }

  # Reduce resource requirements for faster startup
  set {
    name  = "controller.resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "controller.resources.requests.memory"
    value = "90Mi"
  }

  depends_on = [time_sleep.wait_for_namespace]
}

# Wait for load balancer to be provisioned
resource "time_sleep" "wait_for_load_balancer" {
  count = var.install_nginx_ingress ? 1 : 0
  
  depends_on = [helm_release.nginx_ingress]
  create_duration = "300s"  # Wait 5 minutes for AWS LB provisioning
}

# Create cert-manager namespace
resource "kubernetes_namespace" "cert_manager" {
  count    = var.install_cert_manager ? 1 : 0
  provider = kubernetes.eks
  
  metadata {
    name = "cert-manager"
    labels = {
      name = "cert-manager"
    }
  }
  
  depends_on = [module.eks]
}

# Wait for cert-manager namespace
resource "time_sleep" "wait_for_cert_manager_namespace" {
  count = var.install_cert_manager ? 1 : 0
  
  depends_on = [kubernetes_namespace.cert_manager]
  create_duration = "30s"
}

# Install cert-manager CRDs first
resource "helm_release" "cert_manager_crds" {
  count            = var.install_cert_manager ? 1 : 0
  provider         = helm.eks
  name             = "cert-manager-crds"
  namespace        = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.13.2"
  create_namespace = false  # Already created above
  timeout          = 600
  wait             = true

  set {
    name  = "installCRDs"
    value = "true"
  }

  # Only install CRDs, disable other components
  set {
    name  = "webhook.enabled"
    value = "false"
  }

  set {
    name  = "cainjector.enabled"
    value = "false"
  }

  set {
    name  = "controller.enabled"
    value = "false"
  }

  depends_on = [time_sleep.wait_for_cert_manager_namespace]
}

# Wait for CRDs to be ready
resource "time_sleep" "wait_for_crds" {
  count = var.install_cert_manager ? 1 : 0
  
  depends_on = [helm_release.cert_manager_crds]
  create_duration = "60s"
}

# Install cert-manager main components
resource "helm_release" "cert_manager" {
  count            = var.install_cert_manager ? 1 : 0
  provider         = helm.eks
  name             = "cert-manager"
  namespace        = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.13.2"
  timeout          = 600
  wait             = true
  wait_for_jobs    = true

  set {
    name  = "installCRDs"
    value = "false"  # CRDs already installed above
  }

  set {
    name  = "extraArgs[0]"
    value = "--enable-certificate-owner-ref=true"
  }

  depends_on = [time_sleep.wait_for_crds]
}

# Wait for cert-manager to be ready before creating ClusterIssuers
resource "time_sleep" "wait_for_cert_manager" {
  count = var.install_cert_manager ? 1 : 0
  
  depends_on = [helm_release.cert_manager]
  create_duration = "60s"
}

# Production ClusterIssuer
resource "kubernetes_manifest" "letsencrypt_prod" {
  count    = var.install_cert_manager && var.letsencrypt_email != "" ? 1 : 0
  provider = kubernetes.eks

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-prod"
    }
    spec = {
      acme = {
        email  = var.letsencrypt_email
        server = "https://acme-v02.api.letsencrypt.org/directory"
        privateKeySecretRef = {
          name = "letsencrypt-prod"
        }
        solvers = [{
          http01 = {
            ingress = {
              class = "nginx"
            }
          }
        }]
      }
    }
  }

  depends_on = [time_sleep.wait_for_cert_manager]
}

# Staging ClusterIssuer
resource "kubernetes_manifest" "letsencrypt_staging" {
  count    = var.install_cert_manager && var.letsencrypt_email != "" ? 1 : 0
  provider = kubernetes.eks

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-staging"
    }
    spec = {
      acme = {
        email  = var.letsencrypt_email
        server = "https://acme-staging-v02.api.letsencrypt.org/directory"
        privateKeySecretRef = {
          name = "letsencrypt-staging"
        }
        solvers = [{
          http01 = {
            ingress = {
              class = "nginx"
            }
          }
        }]
      }
    }
  }

  depends_on = [time_sleep.wait_for_cert_manager]
}