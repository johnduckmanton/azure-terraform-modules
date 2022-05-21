output "account_id" {
  value = azurerm_cosmosdb_account.cosmos.id
}

output "account_endpoint" {
  value = azurerm_cosmosdb_account.cosmos.endpoint
}

output "account_read_endpoints" {
  value = azurerm_cosmosdb_account.cosmos.read_endpoints
}

output "account_write_endpoints" {
  value = azurerm_cosmosdb_account.cosmos.write_endpoints
}

output "account_primary_master_key" {
  value = azurerm_cosmosdb_account.cosmos.primary_master_key
}

output "account_secondary_master_key" {
  value = azurerm_cosmosdb_account.cosmos.secondary_master_key
}

output "account_primary_readonly_master_key" {
  value = azurerm_cosmosdb_account.cosmos.primary_readonly_master_key
}

output "account_secondary_readonly_master_key" {
  value = azurerm_cosmosdb_account.cosmos.secondary_readonly_master_key
}

output "account_connection_strings" {
  value = azurerm_cosmosdb_account.cosmos.connection_strings
}

output "table_id" {
  value = azurerm_cosmosdb_table.cosmos.*.id
}
