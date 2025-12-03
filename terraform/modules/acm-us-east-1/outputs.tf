output "acm_cert_arn" {
  value = try(aws_acm_certificate.cert[0].arn, "")
  description = "ACM certificate ARN created in us-east-1"
}
