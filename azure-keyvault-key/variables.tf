variable "key_type" {
  default = "RSA-HSM"
}

variable "key_size" {
  default = "2048"
}

variable "kv_id" {}

variable "key_name" {}

variable "tags" {
  type = map(string)
}
