variable "db_name" {
	type = string
}

variable "username" {
	type = string
}

variable "password" {
	type = string
}

variable "instance_class" {
	type    = string
	default = "db.t3.micro"
}

variable "allocated_storage" {
	type    = number
	default = 20
}

variable "subnet_ids" {
	type = list(string)
}

variable "vpc_security_group_ids" {
	type = list(string)
}

variable "multi_az" {
	type    = bool
	default = false
}

variable "public_access" {
	type    = bool
	default = false
}

variable "skip_final_snapshot" {
	type    = bool
	default = false
}

variable "tags" {
	type    = map(string)
	default = {}
}
