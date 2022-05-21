resource "azurerm_key_vault_access_policy" "kvap" {
  key_vault_id            = var.key_vault_id
  object_id               = var.ad_object_id
  tenant_id               = var.tenant_id
  key_permissions         = var.key_permissions
  secret_permissions      = var.secret_permissions
  certificate_permissions = var.certificate_permissions
}

resource "null_resource" "dependency_getter" {
  triggers = {
    my_dependencies = join(",", var.dependencies)
  }
}

resource "null_resource" "dependency_setter" {
  depends_on = [
    azurerm_key_vault_access_policy.kvap
  ]
}