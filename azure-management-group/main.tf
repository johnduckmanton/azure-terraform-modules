resource "azurerm_management_group" "mg" {
  display_name               = var.name
  parent_management_group_id = var.parent_management_group_id
  subscription_ids           = var.subscription_ids
  group_id                   = var.name
}
