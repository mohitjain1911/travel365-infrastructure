variable "name" {
	type = string
}

variable "cluster_name" {
	type = string
}

variable "log_group_name" {
	type = string
}

variable "tags" {
	type = map(string)
	default = {}
}
