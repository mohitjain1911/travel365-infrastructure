variable "name" { type = string }
variable "scope" {
	type    = string
	default = "REGIONAL"
}

variable "rules" {
	type    = list(any)
	default = []
}

variable "visibility_config" {
	type = map(any)
	default = {
		sampled_requests_enabled     = true
		cloudwatch_metrics_enabled   = true
		metric_name                  = "waf"
	}
}

variable "tags" {
	type    = map(string)
	default = {}
}
