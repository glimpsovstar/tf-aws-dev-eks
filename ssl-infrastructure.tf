# Install NGINX Ingress Controller
resource "helm_release" "nginx_ingress" {
  name             = "nginx-ingress"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.8.3"
  namespace        = "ingress-nginx"
  create_namespace = true
  timeout          = 600

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
}

resource "helm_release" "cert_manager_crds" {
  name             = "cert-manager-crds"
  namespace        = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.13.2"

  set {
    name  = "installCRDs"
    value = "true"
  }
}

# Install cert-manager with CRDs - FIXED VERSION
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.13.2"
  timeout    = 600

  depends_on = [helm_release.cert_manager_crds]

  # CRITICAL: This installs the CRDs
  set {
    name  = "installCRDs"
    value = "false"  # Set to false to avoid re-installing CRDs
  }

  set {
    name  = "extraArgs[0]"
    value = "--enable-certificate-owner-ref=true"
  }

  # Wait for CRDs to be ready before proceeding
  wait          = true
  wait_for_jobs = true
}


# Create Let's Encrypt ClusterIssuer for production
resource "kubernetes_manifest" "letsencrypt_prod_issuer" {
   depends_on = [null_resource.wait_for_clusterissuer_crd]

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
}

# Create Let's Encrypt ClusterIssuer for staging (testing)
resource "kubernetes_manifest" "letsencrypt_staging_issuer" {
   depends_on = [null_resource.wait_for_clusterissuer_crd]

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-staging"
    }
    spec = {
      acme = {
        email  = var.letsencrypt_email
        server = "https://acme-v02.api.letsencrypt.org/directory/staging"
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
}

resource "null_resource" "wait_for_clusterissuer_crd" {
  depends_on = [helm_release.cert_manager]

  provisioner "local-exec" {
    command = <<EOT
      echo "Waiting for ClusterIssuer CRD to exist..."
      until kubectl get crd clusterissuers.cert-manager.io; do
        echo "Still waiting for ClusterIssuer CRD..."
        sleep 5
      done
    EOT
  }
}