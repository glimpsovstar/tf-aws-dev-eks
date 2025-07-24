# KMS key for Vault auto-unseal
resource "aws_kms_key" "vault" {
  description             = "KMS key for Vault auto-unseal"
  deletion_window_in_days = 7
  
  tags = {
    Name        = "${var.cluster_name}-vault-kms"
    Environment = var.environment
  }
}

resource "aws_kms_alias" "vault" {
  name          = "alias/${var.cluster_name}-vault"
  target_key_id = aws_kms_key.vault.key_id
}