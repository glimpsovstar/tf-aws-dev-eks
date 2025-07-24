# Security group for Vault
resource "aws_security_group" "vault" {
  name_prefix = "${var.cluster_name}-vault-"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for Vault cluster"
  
  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
    description = "Vault API"
  }
  
  ingress {
    from_port   = 8201
    to_port     = 8201
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
    description = "Vault cluster communication"
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.cluster_name}-vault"
  }
}