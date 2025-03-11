module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = "1.28"

  vpc_id     = data.terraform_remote_state.aws_dev_vpc.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.aws_dev_vpc.outputs.subnet_ids

  eks_managed_node_groups = {
    default = {
      desired_size  = 2
      max_size      = 3
      min_size      = 2
      instance_types = [var.instance_type]
    }
  }
}

