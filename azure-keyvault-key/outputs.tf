output "id" {
  value = azurerm_key_vault_key.generated.id
}

output "version" {
  value = azurerm_key_vault_key.generated.version
}

output "url" {
  value = azurerm_key_vault_key.generated.vault_uri
}

output "name" {
  value = azurerm_key_vault_key.generated.name
}