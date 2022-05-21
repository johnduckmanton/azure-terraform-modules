output "fqdn" {
  description = "The fqdn of MySQL Server."
  value       = azurerm_mysql_server.server.fqdn
}

output "server_name" {
  description = "The server name of MySQL Server."
  value       = azurerm_mysql_server.server.name
}

output "server_id" {
  description = "The ID of the server resource"
  value       = azurerm_mysql_server.server.id
}

output "admin_username" {
  description = "The administrator username of MySQL Server."
  value       = local.admin_username
}

output "admin_password" {
  description = "The administrator password of MySQL Server."
  value       = local.password
  sensitive   = true
}