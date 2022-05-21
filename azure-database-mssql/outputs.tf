output "server_name" {
  description = "The server name of MySQL Server."
  value       = azurerm_mssql_server.server.name
}

output "server_id" {
  description = "The ID of the server resource"
  value       = azurerm_mssql_server.server.id
}

output "admin_username" {
  description = "The administrator username of MySQL Server."
  value       = local.administrator_login
}

output "admin_password" {
  description = "The administrator password of MySQL Server."
  value       = local.administrator_login_password
  sensitive   = true
}
