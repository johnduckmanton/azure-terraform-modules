output "vm_id" {
  value = azurerm_virtual_machine.vm.*.id
}

output "vm_name" {
  value = azurerm_virtual_machine.vm.*.name
}

output "identity" {
  value = azurerm_virtual_machine.vm.*.identity
}

output "img_vm_id" {
  value = azurerm_virtual_machine.vm_from_image.*.id
}

output "img_vm_name" {
  value = azurerm_virtual_machine.vm_from_image.*.name
}

output "img_vm_identity" {
  value = azurerm_virtual_machine.vm_from_image.*.identity
}

output "nic_id" {
  value = azurerm_network_interface.nic.id
}

output "depended_on" {
  value = "${null_resource.dependency_setter.id}-${timestamp()}"
}
