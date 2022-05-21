output "windows_id" {
  description = "The ID of the Windows Virtual Machine."
  value       = azurerm_windows_virtual_machine.base[*].id
}

output "windows_name" {
  description = "The Name of the Windows Virtual Machine."
  value       = azurerm_windows_virtual_machine.base[*].name
}

output "linux_id" {
  description = "The ID of the Linux Virtual Machine."
  value       = azurerm_linux_virtual_machine.base[*].id
}

output "linux_name" {
  description = "The Name of the Linux Virtual Machine."
  value       = azurerm_linux_virtual_machine.base[*].name
}

output "admin_username" {
  description = "The admin username assigned to the VM"
  value       = local.admin_username
}

output "admin_password" {
  description = "The admin password assigned to the VM"
  value       = local.admin_password
  sensitive   = true
}