variable "remote_virtual_network_name" {}
variable "remote_resource_group_name" {}
variable "local_virtual_network_name" {}
variable "local_resource_group_name" {}

variable "allow_forwarded_traffic" {
  default = false
}

variable "allow_gateway_transit" {
  default = false
}

variable "allow_virtual_network_access" {
  default = true
}

variable "use_remote_gateways" {
  default = false
}
