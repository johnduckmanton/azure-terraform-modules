variable "name_prefix" {}
variable "resource_id" {}
variable "log_categories" {}
variable "log_retention_days" {}
variable "metric_categories" {}

variable "log_analytics_destination_type" {
  default = "Dedicated"
}

variable "storage_account_id" {
  default = null
}

variable "eventhub_name" {
  default = null
}

variable "log_analytics_workspace_id" {
  default = null
}
