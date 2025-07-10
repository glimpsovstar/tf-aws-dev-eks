module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.37.1"
  cluster_name    = var.eks_cluster_name
  cluster_version = var.eks_cluster_version
  enable_cluster_creator_admin_permissions = true

  vpc_id     = data.terraform_remote_state.aws_dev_vpc.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.aws_dev_vpc.outputs.vpc_private_subnets

  enable_irsa = true

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  cluster_security_group_additional_rules = {
    inbound_allow_eks_api = {
      description = "Allow public access to EKS API"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  eks_managed_node_groups = {
    default = {
      desired_size   = 2
      max_size       = 4
      min_size       = 2
      instance_types = [var.instance_type]
      
      # Ensure nodes can handle addon workloads
      capacity_type = "ON_DEMAND"
    }
  }

  cluster_addons = {
    coredns    = { most_recent = true }
    kube-proxy = { most_recent = true }
    vpc-cni    = { most_recent = true }
  }
}