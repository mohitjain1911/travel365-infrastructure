variable "name" {
	type = string
}

variable "subnet_ids" {
	type = list(string)
}

variable "redis_sg_id" {
	type = string
}

variable "node_type" {
	type    = string
	default = "cache.t4g.micro"
}

variable "engine_version" {
	type    = string
	default = "7.0"
}

variable "tags" {
	type    = map(string)
	default = {}
}

variable "enabled" {
	type    = bool
	default = true
}
