variable "name" {}
variable "rg_name" {}
variable "kv_number" {}
variable "location" {}
variable "tenant_id" {}

variable "vnet_subnet_ids" {
  type    = list(string)
  default = []
}

variable "proxy_cidrs" {
  type    = list(string)
  default = []
}

variable "enable_purge_protection" {
  default = false
}

variable "public" {
  default = true
}

variable "tags" {
  type = map(string)
}