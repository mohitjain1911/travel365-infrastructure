resource "aws_route53_zone" "this" {
  count = var.create_hosted_zone ? 1 : 0
  name = var.domain_name
  force_destroy = true
}

resource "aws_acm_certificate" "cert" {
  count = var.create_hosted_zone && var.domain_name != "" ? 1 : 0
  domain_name = var.domain_name
  validation_method = "DNS"
  lifecycle { create_before_destroy = true }
}

# DNS validation records
resource "aws_route53_record" "cert_validation" {
  for_each = length(aws_acm_certificate.cert) > 0 ? { for dvo in aws_acm_certificate.cert[0].domain_validation_options : dvo.resource_record_name => dvo } : {}
  zone_id = aws_route53_zone.this[0].zone_id
  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  records = [each.value.resource_record_value]
  ttl     = 300
}
