variable "tags" {}
variable "rg_name" {}
variable "name" {}
variable "short_name" {}

variable "actiongroup_name" {
  default = "ActivityLogsAlerts"
}

variable "actiongroup_email" {
  default = null
}

variable "webhook_name" {
  default = "ServiceNow"
}

variable "webhook_uri" {
  default = null
}