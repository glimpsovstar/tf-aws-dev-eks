# Add this to your EKS foundation repository
# File: route53-base.tf

# Data source for the main Route53 hosted zone
data "aws_route53_zone" "main" {
  name         = var.route53_zone_name
  private_zone = false
}

# Optional: Create EKS subdomain zone (if you want delegation)
resource "aws_route53_zone" "eks_subdomain" {
  count = var.create_eks_subdomain_zone ? 1 : 0
  name  = var.eks_subdomain_zone

  tags = {
    Name        = "EKS Subdomain Zone"
    Environment = var.environment
    Purpose     = "eks-services"
  }
}

# Create NS record in main zone pointing to subdomain zone (if creating subdomain zone)
resource "aws_route53_record" "eks_subdomain_ns" {
  count   = var.create_eks_subdomain_zone ? 1 : 0
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.eks_subdomain_zone
  type    = "NS"
  ttl     = 300
  records = aws_route53_zone.eks_subdomain[0].name_servers
}