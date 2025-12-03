variable "bucket_name" {
	type = string
}

variable "name" {
	type = string
}

variable "versioning" {
	type    = bool
	default = true
}

variable "public_access" {
	type    = bool
	default = false
}

variable "kms_key_id" {
	type    = string
	default = ""
}

variable "tags" {
	type    = map(string)
	default = {}
}
