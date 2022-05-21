variable "retention_days" {}
variable "event_hub_name" {}
variable "subscription_id" {}

variable "auth_name" {
  default = "RootManageSharedAccessKey"
}

variable "auth_namespace_name" {
  default = "group-foundserv-prod-rg-eventhub-securitylogging"
}

variable "auth_resource_group_name" {
  default = "group-foundserv-prod-rg-eventhub"
}

variable "log_categories" {
  default = [
    "Administrative",
    "Security",
    "Policy"
  ]
}

variable "require_retention" {
  default = false
}