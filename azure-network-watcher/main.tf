resource "azurerm_network_watcher" "watcher" {
  for_each            = toset(var.locations)
  name                = format("NetworkWatcher-%s", each.value)
  location            = each.value
  resource_group_name = var.rg_name
  tags                = var.tags
}