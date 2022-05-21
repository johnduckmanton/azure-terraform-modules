data "azurerm_virtual_network" "local" {
  name                = var.local_virtual_network_name
  resource_group_name = var.local_resource_group_name
}

data "azurerm_virtual_network" "remote" {
  name                = var.remote_virtual_network_name
  resource_group_name = var.remote_resource_group_name
}

resource "azurerm_virtual_network_peering" "local" {
  name                         = format("%s-peer", var.remote_virtual_network_name)
  resource_group_name          = var.local_resource_group_name
  virtual_network_name         = var.local_virtual_network_name
  remote_virtual_network_id    = data.azurerm_virtual_network.remote.id
  allow_forwarded_traffic      = var.allow_forwarded_traffic
  allow_gateway_transit        = var.allow_gateway_transit
  allow_virtual_network_access = var.allow_virtual_network_access
  use_remote_gateways          = var.use_remote_gateways
}

resource "azurerm_virtual_network_peering" "remote" {
  name                         = format("%s-peer", var.local_virtual_network_name)
  resource_group_name          = var.remote_resource_group_name
  virtual_network_name         = var.remote_virtual_network_name
  remote_virtual_network_id    = data.azurerm_virtual_network.local.id
  allow_forwarded_traffic      = var.allow_forwarded_traffic
  allow_gateway_transit        = var.allow_gateway_transit
  allow_virtual_network_access = var.allow_virtual_network_access
  use_remote_gateways          = var.use_remote_gateways
}
