variable "name" {
	type = string
}

variable "fifo" {
	type    = bool
	default = false
}

variable "tags" {
	type    = map(string)
	default = {}
}
