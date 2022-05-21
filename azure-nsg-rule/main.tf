resource "azurerm_network_security_rule" "rule" {
  for_each = var.rules

  access                      = each.value["access"]
  direction                   = each.value["direction"]
  name                        = format("%s_%s_%s_%s", each.value["access"], each.value["direction"], each.value["protocol"], each.value["priority"])
  description                 = format("%s %s %s %s", each.value["access"], each.value["direction"], each.value["protocol"], each.value["protocol"])
  priority                    = each.value["priority"]
  protocol                    = each.value["protocol"]
  resource_group_name         = var.rg_name
  network_security_group_name = var.nsg_name

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