variable "scope_id" {}

variable "policies" {
  type        = map(map(string))
  description = "Map of maps of policies to apply to the resource group"
  default     = {}
}
