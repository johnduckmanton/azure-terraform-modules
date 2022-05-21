variable "action_group_id" {}
variable "scope" {}
variable "rg_name" {}
variable "criteria_status" {}
variable "description" {}

variable "name" {
  type = list(string)
}

variable "resource_type" {
  type = list(string)
}

variable "operation_name" {
  type = list(string)
}

variable "category" {
  default = "Administrative"
}

variable "tags" {
  type = map(string)
}

variable "caller" {
  type = list(string)
}
