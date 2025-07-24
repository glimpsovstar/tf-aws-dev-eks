# KMS key for Vault auto-unseal
resource "aws_kms_key" "vault" {
  description             = "KMS key for Vault auto-unseal"
  deletion_window_in_days = 7
  
  tags = {
    Name        = "${var.eks_cluster_name}-vault-kms"  # Fixed: Use consistent variable name
    Environment = var.environment
  }
}

resource "aws_kms_alias" "vault" {
  name          = "alias/${var.eks_cluster_name}-vault"  # Fixed: Use consistent variable name
  target_key_id = aws_kms_key.vault.key_id
}