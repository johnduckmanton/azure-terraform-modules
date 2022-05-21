resource "azurerm_role_assignment" "role" {
  scope                = var.subscription_id
  role_definition_name = var.role_definition_name
  principal_id         = var.object_id
}
