variable "table_names" {}
variable "rg_name" {}
variable "account_name" {}
variable "tags" {}
variable "region" {}

variable "throughput" {
  default = 400
}

variable "offer_type" {
  default = "Standard"
}

variable "kind" {
  default = "GlobalDocumentDB"
}

variable "enable_automatic_failover" {
  default = false
}

variable "ip_range_filter" {
  default = ""
}

variable "is_virtual_network_filter_enabled" {
  default = false
}

variable "enable_multiple_write_locations" {
  default = false
}

variable "consistency_level" {
  default = "BoundedStaleness"
}

variable "max_interval_in_seconds" {
  default = "10"
}

variable "max_staleness_prefix" {
  default = "200"
}

variable "failover_location" {
  default = ""
}

variable "failover_region" {
  default = ""
}

variable "vnet_id" {
  default = ""
}

variable "capabilities" {
  default = ""
}
