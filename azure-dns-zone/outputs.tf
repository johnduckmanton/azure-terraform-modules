output "id" {
  value = azurerm_dns_zone.zone.id
}

output "name_servers" {
  value = azurerm_dns_zone.zone.name_servers
}