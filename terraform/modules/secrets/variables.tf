variable "name" {
	type = string
}

variable "secret_string" {
	type = string
}

variable "tags" {
	type    = map(string)
	default = {}
}
