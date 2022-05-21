resource "azurerm_cosmosdb_account" "cosmos" {
  name                              = var.account_name
  resource_group_name               = var.rg_name
  location                          = var.region
  offer_type                        = var.offer_type
  kind                              = var.kind
  enable_automatic_failover         = var.enable_automatic_failover
  ip_range_filter                   = var.ip_range_filter
  is_virtual_network_filter_enabled = var.is_virtual_network_filter_enabled
  enable_multiple_write_locations   = var.enable_multiple_write_locations
  consistency_policy {
    consistency_level       = var.consistency_level
    max_interval_in_seconds = var.max_interval_in_seconds
    max_staleness_prefix    = var.max_staleness_prefix
  }
  //  geo_location {
  //    location          = length(var.failover_location) > 0 ? var.failover_region : ""
  //    failover_priority = length(var.failover_location) > 0 ? 1 : ""
  //  }
  geo_location {
    prefix            = format("%s-%s", var.account_name, var.region)
    location          = var.region
    failover_priority = 0
  }
  //  virtual_network_rule {
  //    id = length(var.vnet_id) > 0 ? var.vnet_id : ""
  //  }
  //  capabilities {
  //    name = length(var.capabilities) > 0 ? var.capabilities : ""
  //  }
  tags = merge(
    var.tags,
    { terraform = "true" }
  )
}

resource "azurerm_cosmosdb_table" "cosmos" {
  name                = var.table_names[count.index]
  resource_group_name = var.rg_name
  account_name        = azurerm_cosmosdb_account.cosmos.name
  throughput          = var.throughput
  count               = length(var.table_names)
}
