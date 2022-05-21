locals {
  vm_name_prefix        = lookup(var.vm_location_prefix_map, replace(lower(var.location), " ", ""), "na")
  vm_environment_prefix = lookup(var.vm_env_prefix_name, lower(var.environment), "d")
  vm_name               = upper(format("%sl%saz%s", local.vm_name_prefix, local.vm_environment_prefix, var.vm_8_custom))
  nic_name              = format("%s-nic1", lower(local.vm_name))
}

resource "azurerm_network_interface" "nic" {
  location                  = var.location
  name                      = local.nic_name
  resource_group_name       = var.resource_group_name
  network_security_group_id = var.nsg_id
  ip_configuration {
    name                          = format("%s-ipconfig", local.vm_name)
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = length(azurerm_public_ip.pip.*.id) > 0 ? azurerm_public_ip.pip[0].id : ""
  }
  tags = merge(
    var.tags,
    { terraform = "true" }
  )
}

resource "azurerm_virtual_machine" "vm" {
  location                      = var.location
  name                          = local.vm_name
  network_interface_ids         = [azurerm_network_interface.nic.id]
  resource_group_name           = var.resource_group_name
  vm_size                       = var.vm_size
  delete_os_disk_on_termination = true
  storage_os_disk {
    create_option     = "FromImage"
    name              = format("%s-osdisk", local.vm_name)
    caching           = "ReadWrite"
    managed_disk_type = "Premium_LRS"
    disk_size_gb      = var.vm_disk_size
  }
  storage_image_reference {
    id        = var.image_id
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
    version   = var.img_version
  }
  os_profile {
    admin_username = var.admin_username
    admin_password = var.admin_password
    computer_name  = local.vm_name
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  boot_diagnostics {
    enabled     = length(var.sa_uri) > 0 ? true : false
    storage_uri = var.sa_uri
  }
  identity {
    type = var.create_msi ? "SystemAssigned" : ""
  }
  tags  = var.tags
  count = length(var.image_id) > 0 ? 0 : 1
}

resource "azurerm_virtual_machine" "vm_from_image" {
  location                      = var.location
  name                          = local.vm_name
  network_interface_ids         = [azurerm_network_interface.nic.id]
  resource_group_name           = var.resource_group_name
  vm_size                       = var.vm_size
  delete_os_disk_on_termination = true
  storage_os_disk {
    create_option     = "FromImage"
    name              = format("%s-osdisk", local.vm_name)
    caching           = "ReadWrite"
    managed_disk_type = "Premium_LRS"
    disk_size_gb      = var.vm_disk_size
  }
  storage_image_reference {
    id = var.image_id
  }
  os_profile {
    admin_username = var.admin_username
    admin_password = var.admin_password
    computer_name  = local.vm_name
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  boot_diagnostics {
    enabled     = length(var.sa_uri) > 0 ? true : false
    storage_uri = var.sa_uri
  }
  identity {
    type = "SystemAssigned"
  }
  tags  = var.tags
  count = length(var.image_id) > 0 ? 1 : 0
}

resource "azurerm_public_ip" "pip" {
  name                = format("%s-pubip", local.vm_name)
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
  tags                = var.tags
  count               = var.public ? 1 : 0
}

resource "null_resource" "dependency_setter" {
  depends_on = [
    azurerm_public_ip.pip,
    azurerm_virtual_machine.vm_from_image,
    azurerm_network_interface.nic,
    azurerm_virtual_machine.vm,
  ]
}
