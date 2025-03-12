module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.eks_cluster_name
  cluster_version = var.eks_cluster_version

  vpc_id     = data.terraform_remote_state.aws_dev_vpc.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.aws_dev_vpc.outputs.subnet_ids

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

resource "aws_lb" "vault_alb" {
  name               = "vault-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.eks.cluster_security_group_id]
  subnets            = data.terraform_remote_state.aws_dev_vpc.outputs.subnet_ids
}

resource "aws_lb_listener" "vault_https" {
  load_balancer_arn = aws_lb.vault_alb.arn
  port              = 8200
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.vault_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vault.arn
  }
}

resource "aws_lb_target_group" "vault" {
  name        = "vault-tg"
  port        = 8200
  protocol    = "HTTPS"
  vpc_id      = data.terraform_remote_state.aws_dev_vpc.outputs.vpc_id
  target_type = "ip"
}

resource "aws_acm_certificate" "vault_cert" {
  domain_name       = var.vault_domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_policy" "eks_load_balancer_controller" {
  name        = "eks-load-balancer-controller-policy"
  description = "Allows EKS to manage ALB and NLB"
  policy      = file(${path.module}/"load-balancer-policy.json")
}

resource "aws_iam_role_policy_attachment" "eks_load_balancer_attach" {
  policy_arn = aws_iam_policy.eks_load_balancer_controller.arn
  role       = module.eks.cluster_iam_role_name

}

