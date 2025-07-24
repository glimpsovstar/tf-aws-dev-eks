# Security group for Vault
resource "aws_security_group" "vault" {
  name_prefix = "${var.eks_cluster_name}-vault-"  # Fixed: Use consistent variable name
  vpc_id      = data.terraform_remote_state.aws_dev_vpc.outputs.vpc_id  # Fixed: Use remote state VPC reference
  description = "Security group for Vault cluster"
  
  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.aws_dev_vpc.outputs.vpc_cidr_block]  # Fixed: Use remote state VPC CIDR
    description = "Vault API"
  }
  
  ingress {
    from_port   = 8201
    to_port     = 8201
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.aws_dev_vpc.outputs.vpc_cidr_block]  # Fixed: Use remote state VPC CIDR
    description = "Vault cluster communication"
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "${var.eks_cluster_name}-vault"
    Environment = var.environment
  }
}