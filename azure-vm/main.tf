locals {
  calculated_value_os_publisher = "${element(split(",", lookup(var.standard_os, var.vm_os_simple, "")), 0)}"
  calculated_value_os_offer     = "${element(split(",", lookup(var.standard_os, var.vm_os_simple, "")), 1)}"
  calculated_value_os_sku       = "${element(split(",", lookup(var.standard_os, var.vm_os_simple, "")), 2)}"
  calculated_remote_port        = "${element(split(",", lookup(var.standard_os, var.vm_os_simple, "")), 0) == "MicrosoftWindowsServer" ? 3389 : 22}"
}

data "azurerm_resource_group" "vm" {
  name = var.resource_group_name
}

resource "random_id" "vm-sa" {
  keepers = {
    vm_hostname = var.vm_hostname
  }

  byte_length = 6
}

resource "azurerm_storage_account" "vm-sa" {
  count                    = var.boot_diagnostics ? 1 : 0
  name                     = "bootdiag${lower(random_id.vm-sa.hex)}"
  resource_group_name      = data.azurerm_resource_group.vm.name
  location                 = data.azurerm_resource_group.vm.location
  account_tier             = element(split("_", var.boot_diagnostics_sa_type), 0)
  account_replication_type = element(split("_", var.boot_diagnostics_sa_type), 1)
  tags                     = var.tags
}

resource "azurerm_virtual_machine" "vm-linux" {
  count                         = ! contains(list(var.vm_os_simple, var.vm_os_offer), "Windows") && ! var.is_windows_image ? var.count_instances : 0
  name                          = "${var.vm_hostname}-vmLinux-${count.index}"
  resource_group_name           = data.azurerm_resource_group.vm.name
  location                      = data.azurerm_resource_group.vm.location
  availability_set_id           = azurerm_availability_set.vm.id
  vm_size                       = var.vm_size
  network_interface_ids         = [element(azurerm_network_interface.vm.*.id, count.index)]
  delete_os_disk_on_termination = var.delete_os_disk_on_termination

  storage_image_reference {
    id        = var.vm_os_id
    publisher = var.vm_os_id == "" ? coalesce(var.vm_os_publisher, local.calculated_value_os_publisher) : ""
    offer     = var.vm_os_id == "" ? coalesce(var.vm_os_offer, local.calculated_value_os_offer) : ""
    sku       = var.vm_os_id == "" ? coalesce(var.vm_os_sku, local.calculated_value_os_sku) : ""
    version   = var.vm_os_id == "" ? var.vm_os_version : ""
  }

  storage_os_disk {
    name              = "osdisk-${var.vm_hostname}-${count.index}"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = var.storage_account_type
  }

  dynamic storage_data_disk {
    for_each = range(var.count_data_disk)
    content {
      name              = "${var.vm_hostname}-datadisk-${count.index}-${storage_data_disk.value}"
      create_option     = "Empty"
      lun               = storage_data_disk.value
      disk_size_gb      = var.data_disk_size_gb
      managed_disk_type = var.data_sa_type
    }
  }

  os_profile {
    computer_name  = "${var.vm_hostname}-${count.index}"
    admin_username = var.admin_username
    admin_password = var.admin_password
    custom_data    = var.custom_data
  }

  os_profile_linux_config {
    disable_password_authentication = var.enable_ssh_key

    dynamic ssh_keys {
      for_each = var.enable_ssh_key ? [var.ssh_key] : []
      content {
        path     = "/home/${var.admin_username}/.ssh/authorized_keys"
        key_data = file(var.ssh_key)
      }
    }
  }

  tags = merge(
    var.tags,
    { terraform = "true" }
  )

  boot_diagnostics {
    enabled     = var.boot_diagnostics
    storage_uri = var.boot_diagnostics ? join(",", azurerm_storage_account.vm-sa.*.primary_blob_endpoint) : ""
  }
}

resource "azurerm_virtual_machine" "vm-windows" {
  count                         = (var.is_windows_image || contains(list(var.vm_os_simple, var.vm_os_offer), "Windows")) ? var.count_instances : 0
  name                          = "${var.vm_hostname}-vmWindows-${count.index}"
  resource_group_name           = data.azurerm_resource_group.vm.name
  location                      = data.azurerm_resource_group.vm.location
  availability_set_id           = azurerm_availability_set.vm.id
  vm_size                       = var.vm_size
  network_interface_ids         = [element(azurerm_network_interface.vm.*.id, count.index)]
  delete_os_disk_on_termination = var.delete_os_disk_on_termination

  storage_image_reference {
    id        = var.vm_os_id
    publisher = var.vm_os_id == "" ? coalesce(var.vm_os_publisher, local.calculated_value_os_publisher) : ""
    offer     = var.vm_os_id == "" ? coalesce(var.vm_os_offer, local.calculated_value_os_offer) : ""
    sku       = var.vm_os_id == "" ? coalesce(var.vm_os_sku, local.calculated_value_os_sku) : ""
    version   = var.vm_os_id == "" ? var.vm_os_version : ""
  }

  storage_os_disk {
    name              = "${var.vm_hostname}-osdisk-${count.index}"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = var.storage_account_type
  }

  dynamic storage_data_disk {
    for_each = range(var.count_data_disk)
    content {
      name              = "${var.vm_hostname}-datadisk-${count.index}-${storage_data_disk.value}"
      create_option     = "Empty"
      lun               = storage_data_disk.value
      disk_size_gb      = var.data_disk_size_gb
      managed_disk_type = var.data_sa_type
    }
  }

  os_profile {
    computer_name  = "${var.vm_hostname}-${count.index}"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  tags = merge(
    var.tags,
    { terraform = "true" }
  )

  os_profile_windows_config {
    provision_vm_agent = true
  }

  boot_diagnostics {
    enabled     = var.boot_diagnostics
    storage_uri = var.boot_diagnostics ? join(",", azurerm_storage_account.vm-sa.*.primary_blob_endpoint) : ""
  }
}

resource "azurerm_availability_set" "vm" {
  name                         = "${var.vm_hostname}-avset"
  resource_group_name          = data.azurerm_resource_group.vm.name
  location                     = data.azurerm_resource_group.vm.location
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
  tags                         = var.tags
}

resource "azurerm_public_ip" "vm" {
  count               = var.count_public_ip
  name                = "${var.vm_hostname}-pip-${count.index}"
  resource_group_name = data.azurerm_resource_group.vm.name
  location            = data.azurerm_resource_group.vm.location
  allocation_method   = var.allocation_method
  domain_name_label   = element(var.public_ip_dns, count.index)
  tags                = var.tags
}

resource "azurerm_network_security_group" "vm" {
  name                = "${var.vm_hostname}-nsg"
  resource_group_name = data.azurerm_resource_group.vm.name
  location            = data.azurerm_resource_group.vm.location

  tags = merge(
    var.tags,
    { terraform = "true" }
  )
}

resource "azurerm_network_security_rule" "vm" {
  name                        = "allow_remote_${coalesce(var.remote_port, local.calculated_remote_port)}_in_all"
  resource_group_name         = data.azurerm_resource_group.vm.name
  description                 = "Allow remote protocol in from all locations"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = coalesce(var.remote_port, local.calculated_remote_port)
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.vm.name
}

resource "azurerm_network_interface" "vm" {
  count                         = var.count_instances
  name                          = "${var.vm_hostname}-nic-${count.index}"
  resource_group_name           = data.azurerm_resource_group.vm.name
  location                      = data.azurerm_resource_group.vm.location
  enable_accelerated_networking = var.enable_accelerated_networking

  ip_configuration {
    name                          = "${var.vm_hostname}-ip-${count.index}"
    subnet_id                     = var.vnet_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = length(azurerm_public_ip.vm.*.id) > 0 ? element(concat(azurerm_public_ip.vm.*.id, list("")), count.index) : ""
  }

  tags = merge(
    var.tags,
    { terraform = "true" }
  )
}

resource "azurerm_network_interface_security_group_association" "test" {
  count                     = var.count_instances
  network_interface_id      = azurerm_network_interface.vm[count.index].id
  network_security_group_id = azurerm_network_security_group.vm.id
}