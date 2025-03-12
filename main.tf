module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.34.0"
  cluster_name    = var.eks_cluster_name
  cluster_version = var.eks_cluster_version

  vpc_id     = data.terraform_remote_state.aws_dev_vpc.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.aws_dev_vpc.outputs.subnet_ids

  enable_irsa = true

  cluster_endpoint_public_access  = true  # Enable Public Access
  cluster_endpoint_private_access = true  # Keep Private Access Enabled

  cluster_security_group_additional_rules = {
    inbound_allow_eks_api = {
      description = "Allow public access to EKS API"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]  # Open to all. Restrict this in production.
    }
  }

  eks_managed_node_groups = {
    default = {
      desired_size   = 2
      max_size       = 3
      min_size       = 2
      instance_types = [var.instance_type]
    }
  }

  cluster_addons = {
    coredns    = { most_recent = true }
    kube-proxy = { most_recent = true }
    vpc-cni    = { most_recent = true }
  }
}

