variable "name" {
	type = string
}

variable "public_subnet_ids" {
	type = list(string)
}

variable "security_group_ids" {
	type = list(string)
}

variable "vpc_id" {
	type = string
}

variable "target_groups" {
	type = map(any)
}

variable "enable_deletion_protection" {
	type    = bool
	default = false
}

variable "tags" {
	type    = map(string)
	default = {}
}
