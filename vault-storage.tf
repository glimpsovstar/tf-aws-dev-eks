# Variable to control vault storage class creation
variable "create_vault_storage" {
  description = "Whether to create Vault storage class"
  type        = bool
  default     = false
}

# Storage class for Vault persistent volumes
# Note: This requires Kubernetes provider to be configured after EKS cluster is ready
# Set create_vault_storage = true only after EKS cluster is fully deployed
resource "kubernetes_storage_class" "vault" {
  count = var.create_vault_storage ? 1 : 0
  
  metadata {
    name = "vault-storage"
  }
  
  storage_provisioner    = "ebs.csi.aws.com"
  allow_volume_expansion = true
  volume_binding_mode    = "WaitForFirstConsumer"
  
  parameters = {
    type      = "gp3"
    encrypted = "true"
  }
  
  depends_on = [module.eks]
}