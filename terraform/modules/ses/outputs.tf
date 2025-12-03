output "domain_identity_arn" { value = try(aws_ses_domain_identity.this[0].arn, "") }
output "dkim_tokens" { value = try(aws_ses_domain_dkim.dkim[0].dkim_tokens, []) }
