# Storage class for Vault persistent volumes
resource "kubernetes_storage_class" "vault" {
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
  
  depends_on = [module.eks]  # Ensure EKS cluster is created first
}