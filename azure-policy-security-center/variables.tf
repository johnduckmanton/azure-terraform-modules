variable "scope" {}
variable "location" {}
variable "management_group_name" {}

variable "auth_name" {
  default = "group_foundserv_prod_rg_eventhub"
}

variable "auth_namespace_name" {
  default = "group-foundserv-prod-rg-eventhub-securitylogging"
}

variable "auth_resource_group_name" {
  default = "group-foundserv-prod-rg-eventhub"
}

variable "event_hub_name" {
  default = "group-foundserv-prod-rg-eventhub-seclog-evhubname"
}
