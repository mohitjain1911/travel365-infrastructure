variable "domain_name" {
	type = string
}

variable "hosted_zone_id" {
	type = string
}

variable "create_cert" {
	type    = bool
	default = true
}

variable "tags" {
	type    = map(string)
	default = {}
}
