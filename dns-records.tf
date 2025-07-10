# Foundation only manages static DNS infrastructure
# No dependencies on addons workspace here

# Static DNS records that don't depend on LoadBalancer
resource "aws_route53_record" "static_records" {
  for_each = var.static_dns_records
  
  zone_id = data.aws_route53_zone.main[0].zone_id
  name    = each.key
  type    = each.value.type
  ttl     = each.value.ttl
  records = each.value.records
}

# Output zone information for other workspaces to use
# This creates no circular dependency