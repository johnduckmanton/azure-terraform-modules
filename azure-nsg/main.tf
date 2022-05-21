resource "azurerm_network_security_group" "nsg" {
  location            = var.location
  name                = var.nsg_name
  resource_group_name = var.rg_name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "rule" {
  for_each = var.rules

  access                      = each.value["access"]
  direction                   = each.value["direction"]
  name                        = format("%s_%s_%s_%s", each.value["access"], each.value["direction"], each.value["protocol"], each.value["priority"])
  description                 = format("%s %s %s %s", each.value["access"], each.value["direction"], each.value["protocol"], each.value["protocol"])
  priority                    = each.value["priority"]
  protocol                    = each.value["protocol"]
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.nsg.name

  source_port_range                     = lookup(each.value, "source_port_range", null)
  source_port_ranges                    = lookup(each.value, "source_port_ranges", null)
  source_address_prefix                 = lookup(each.value, "source_address_prefix", null)
  source_address_prefixes               = lookup(each.value, "source_address_prefixes", null)
  source_application_security_group_ids = lookup(each.value, "source_application_security_group_ids", [])

  destination_port_range                     = lookup(each.value, "destination_port_range", null)
  destination_port_ranges                    = lookup(each.value, "destination_port_ranges", null)
  destination_address_prefix                 = lookup(each.value, "destination_address_prefix", null)
  destination_address_prefixes               = lookup(each.value, "destination_address_prefixes", null)
  destination_application_security_group_ids = lookup(each.value, "destination_application_security_group_ids", [])
}

resource "azurerm_network_watcher_flow_log" "fl" {
  network_watcher_name      = var.fl_network_watcher_name
  resource_group_name       = var.fl_network_watcher_rg_name
  network_security_group_id = azurerm_network_security_group.nsg.id
  storage_account_id        = var.fl_storage_account_id
  enabled                   = true
  version                   = 2

  retention_policy {
    enabled = true
    days    = var.retention_days
  }
}