resource "aws_acm_certificate" "cert" {
  count = var.create_cert && var.domain_name != "" ? 1 : 0
  domain_name       = var.domain_name
  validation_method = "DNS"
  lifecycle { create_before_destroy = true }
}

resource "aws_route53_record" "cert_validation" {
  for_each = length(aws_acm_certificate.cert) > 0 ? { for dvo in aws_acm_certificate.cert[0].domain_validation_options : dvo.resource_record_name => dvo } : {}
  zone_id = var.hosted_zone_id
  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  records = [each.value.resource_record_value]
  ttl     = 300
}

resource "aws_acm_certificate_validation" "cert_validation" {
  count                   = length(aws_acm_certificate.cert) > 0 ? 1 : 0
  certificate_arn         = aws_acm_certificate.cert[0].arn
  validation_record_fqdns = length(values(aws_route53_record.cert_validation)) > 0 ? [for r in values(aws_route53_record.cert_validation) : r.fqdn] : []
}
