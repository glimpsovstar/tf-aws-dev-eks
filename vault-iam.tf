# IAM role for Vault service account
resource "aws_iam_role" "vault" {
  name = "${var.eks_cluster_name}-vault"  # Fixed: Use consistent variable name
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub": "system:serviceaccount:vault:vault"
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:aud": "sts.amazonaws.com"
          }
        }
      }
    ]
  })
  
  tags = {
    Name        = "${var.eks_cluster_name}-vault"
    Environment = var.environment
  }
}

# IAM policy for Vault KMS access
resource "aws_iam_policy" "vault_kms" {
  name        = "${var.eks_cluster_name}-vault-kms"  # Fixed: Use consistent variable name
  description = "IAM policy for Vault KMS access"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:GenerateDataKeyWithoutPlaintext",
          "kms:GenerateRandom",
          "kms:GetKeyPolicy",
          "kms:GetKeyRotationStatus",
          "kms:GetParametersForImport",
          "kms:GetPublicKey",
          "kms:ListKeyPolicies",
          "kms:ListKeys",
          "kms:ListResourceTags"
        ]
        Resource = aws_kms_key.vault.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "vault_kms" {
  role       = aws_iam_role.vault.name
  policy_arn = aws_iam_policy.vault_kms.arn
}

# IAM role for EBS CSI driver
resource "aws_iam_role" "ebs_csi_driver" {
  name = "${var.eks_cluster_name}-ebs-csi-driver"  # Fixed: Use consistent variable name
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:aud": "sts.amazonaws.com"
          }
        }
      }
    ]
  })
  
  tags = {
    Name        = "${var.eks_cluster_name}-ebs-csi-driver"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  role       = aws_iam_role.ebs_csi_driver.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}