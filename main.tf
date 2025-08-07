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

  # Fixed: Consolidated EKS addons configuration (removed duplicate)
  cluster_addons = {
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = aws_iam_role.ebs_csi_driver.arn
    }
    coredns    = { most_recent = true }
    kube-proxy = { most_recent = true }
    vpc-cni    = { most_recent = true }
  }

  # Add kubectl access for additional AWS roles/users
  access_entries = {
    # Add David Joo's AWS role for kubectl access
    david_joo_access = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::521614675974:role/aws_david.joo_test-developer"
      
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
    
    # Add Terraform Cloud role for kubectl access
    terraform_cloud_access = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::521614675974:role/tfstacks-role"
      
      
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
  
  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}