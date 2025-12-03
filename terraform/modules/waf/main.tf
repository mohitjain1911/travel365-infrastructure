resource "aws_wafv2_web_acl" "this" {
  name = var.name
  scope = var.scope
  default_action {
    allow {}
  }
  visibility_config {
    sampled_requests_enabled = lookup(var.visibility_config, "sampled_requests_enabled", true)
    cloudwatch_metrics_enabled = lookup(var.visibility_config, "cloudwatch_metrics_enabled", true)
    metric_name = lookup(var.visibility_config, "metric_name", "waf")
  }
  # var.rules is currently accepted but not expanded into rule blocks here.
  # If you want to provide WAF rules, implement dynamic rule blocks matching the AWS provider schema.
  tags = var.tags
}
