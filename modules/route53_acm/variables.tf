variable "create_hosted_zone" {
	type    = bool
	default = false
}

variable "domain_name" {
	type    = string
	default = ""
}

variable "region" {
	type    = string
	default = "eu-west-2"
}
