variable "tags" {
  type = map(string)
}

variable "rg_name" {}
variable "location" {}
variable "nsg_name" {}
variable "rules" {}
variable "fl_network_watcher_name" {}
variable "fl_network_watcher_rg_name" {}
variable "fl_storage_account_id" {}

variable "retention_days" {
  default = 91
}