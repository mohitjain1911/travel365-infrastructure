output "acm_cert_arn" {
  value = try(aws_acm_certificate.cert[0].arn, "")
  description = "ACM certificate ARN (empty string if not created)"
}

output "hosted_zone_id" {
  value = try(aws_route53_zone.this[0].zone_id, "")
  description = "Hosted zone id created (empty if not created)"
}
