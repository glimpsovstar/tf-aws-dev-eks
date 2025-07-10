# Install NGINX Ingress Controller
resource "helm_release" "nginx_ingress" {
  count            = var.install_nginx_ingress ? 1 : 0
  name             = "nginx-ingress"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.8.3"
  namespace        = "ingress-nginx"
  create_namespace = true
  timeout          = 900

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

  depends_on = [module.eks]
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

  set {
    name  = "webhook.enabled"
    value = "false"
  }

  set {
    name  = "cainjector.enabled"
    value = "false"
  }

  depends_on = [time_sleep.wait_for_load_balancer]
}


resource "helm_release" "cert_manager" {
  count            = var.install_cert_manager ? 1 : 0
  name             = "cert-manager"
  namespace        = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.13.2"
  timeout          = 600
  wait             = true

  set {
    name  = "installCRDs"
    value = "false"  # Already installed above
  }

  depends_on = [helm_release.cert_manager_crds]
}