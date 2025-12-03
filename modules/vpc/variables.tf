variable "name" {
	type = string
}

variable "cidr" {
	type    = string
	default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
	type = list(string)
}

variable "private_subnet_cidrs" {
	type = list(string)
}

variable "enable_nat" {
	type    = bool
	default = true
}

variable "region" {
	type    = string
	default = "eu-west-2"
}

variable "tags" {
	type    = map(string)
	default = {}
}
