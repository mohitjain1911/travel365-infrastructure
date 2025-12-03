resource "aws_ses_domain_identity" "this" {
  count = var.enabled && var.domain_name != "" ? 1 : 0
  domain = var.domain_name
}

resource "aws_ses_domain_dkim" "dkim" {
  count = length(aws_ses_domain_identity.this) > 0 ? 1 : 0
  domain = aws_ses_domain_identity.this[0].domain
}

resource "aws_route53_record" "ses_verification" {
  count = length(aws_ses_domain_identity.this) > 0 && var.hosted_zone_id != "" ? 1 : 0
  zone_id = var.hosted_zone_id
  name = "_amazonses.${var.domain_name}"
  type = "TXT"
  ttl = 300
  records = [aws_ses_domain_identity.this[0].verification_token]
}

resource "aws_route53_record" "ses_dkim_records" {
  for_each = length(aws_ses_domain_dkim.dkim) > 0 && var.hosted_zone_id != "" ? { for t in aws_ses_domain_dkim.dkim[0].dkim_tokens : t => t } : {}
  zone_id = var.hosted_zone_id
  name    = each.key
  type    = "CNAME"
  ttl     = 300
  records = [each.value]
}
