variable "name" {
	type = string
}

variable "s3_bucket_origin" {
	type = string
}

variable "enable_waf" {
	type    = bool
	default = true
}

variable "acm_cert_arn" {
	type    = string
	default = ""
}

variable "domain_name" {
	type    = string
	default = ""
}

variable "enabled" {
	type    = bool
	default = true
}

variable "tags" {
	type    = map(string)
	default = {}
}
