variable "key_vault_id" {}

variable "tenant_id" {}

variable "ad_object_id" {}

variable "key_permissions" {
  type    = list(string)
  default = ["Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore", "Encrypt", "Sign", "Verify", "WrapKey", "UnwrapKey", "Decrypt"]
}

variable "secret_permissions" {
  type    = list(string)
  default = ["backup", "delete", "get", "list", "purge", "recover", "restore", "set"]
}

variable "certificate_permissions" {
  type    = list(string)
  default = ["list"]
}

variable "dependencies" {
  type    = list(string)
  default = [""]
}
