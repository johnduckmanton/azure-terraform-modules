variable "name" {}

variable "parent_management_group_id" {
  default = ""
}

variable "subscription_ids" {
  type = list(string)
}