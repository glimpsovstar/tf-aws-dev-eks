# Install NGINX Ingress Controller
resource "helm_release" "nginx_ingress" {
  count            = var.install_nginx_ingress ? 1 : 0
  name             = "nginx-ingress"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.8.3"
  namespace        = "ingress-nginx"
  create_namespace = true
  timeout          = 600

  provider = helm.eks

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
  count            = var.install_cert_manager ? 1 : 0
  name             = "cert-manager-crds"
  namespace        = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.13.2"
  create_namespace = true

  provider = helm.eks

  set {
    name  = "installCRDs"
    value = "true"
  }
}

# Install cert-manager with CRDs - FIXED VERSION
resource "helm_release" "cert_manager" {
  count            = var.install_cert_manager ? 1 : 0
  name             = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.13.2"
  timeout    = 600

  provider = helm.eks

  depends_on = [helm_release.cert_manager_crds, module.eks]

  # CRITICAL: This installs the CRDs
  set {
    name  = "installCRDs"
    value = "false"  # Set to false to avoid re-installing CRDs
  }

  set {
    name  = "extraArgs[0]"
    value = "--enable-certificate-owner-ref=true"
  }
  set {
    name  = "extraObjects[0].apiVersion"
    value = "cert-manager.io/v1"
  }
  set {
    name  = "extraObjects[0].kind"
    value = "ClusterIssuer"
  }
  set {
    name  = "extraObjects[0].metadata.name"
    value = "letsencrypt-prod"
  }
  set {
    name  = "extraObjects[0].spec.acme.email"
    value = var.letsencrypt_email
  }
  set {
    name  = "extraObjects[0].spec.acme.server"
    value = "https://acme-v02.api.letsencrypt.org/directory"
  }
  set {
    name  = "extraObjects[0].spec.acme.privateKeySecretRef.name"
    value = "letsencrypt-prod"
  }
  set {
    name  = "extraObjects[0].spec.acme.solvers[0].http01.ingress.class"
    value = "nginx"
  }

  set {
    name  = "extraObjects[1].apiVersion"
    value = "cert-manager.io/v1"
  }
  set {
    name  = "extraObjects[1].kind"
    value = "ClusterIssuer"
  }
  set {
    name  = "extraObjects[1].metadata.name"
    value = "letsencrypt-staging"
  }
  set {
    name  = "extraObjects[1].spec.acme.email"
    value = var.letsencrypt_email
  }
  set {
    name  = "extraObjects[1].spec.acme.server"
    value = "https://acme-v02.api.letsencrypt.org/directory/staging"
  }
  set {
    name  = "extraObjects[1].spec.acme.privateKeySecretRef.name"
    value = "letsencrypt-staging"
  }
  set {
    name  = "extraObjects[1].spec.acme.solvers[0].http01.ingress.class"
    value = "nginx"
  }

  # Wait for CRDs to be ready before proceeding
  wait          = true
  wait_for_jobs = true
}
