resource "azurerm_windows_virtual_machine" "base" {
  count = var.is_windows ? var.vm_count : 0

  name                         = format("%s%05d", local.vm_name, var.vm_init_number + count.index)
  resource_group_name          = var.resource_group_name
  location                     = local.location
  size                         = var.size
  admin_username               = local.admin_username
  admin_password               = local.admin_password
  network_interface_ids        = [element(azurerm_network_interface.vm.*.id, count.index)]
  allow_extension_operations   = var.allow_extension_operations
  availability_set_id          = azurerm_availability_set.vm.id
  computer_name                = format("%s%05d", local.vm_name, var.vm_init_number + count.index)
  custom_data                  = var.custom_data
  dedicated_host_id            = var.dedicated_host_id
  enable_automatic_updates     = var.enable_automatic_updates
  eviction_policy              = var.eviction_policy
  license_type                 = var.license_type
  max_bid_price                = var.max_bid_price
  priority                     = var.priority
  provision_vm_agent           = var.provision_vm_agent
  proximity_placement_group_id = var.proximity_placement_group_id
  source_image_id              = var.source_image_id
  timezone                     = var.timezone
  tags = merge(
    var.tags,
    { terraform = "true" }
  )

  os_disk {
    caching                   = var.os_disk_caching
    storage_account_type      = var.os_disk_storage_account_type
    disk_encryption_set_id    = var.os_disk_encryption_set_id
    disk_size_gb              = var.os_disk_size_gb
    name                      = format("%s%05d-osdisk", local.vm_name, var.vm_init_number + count.index)
    write_accelerator_enabled = var.os_disk_write_accelerator_enabled
  }

  dynamic "source_image_reference" {
    for_each = var.source_image_id == null ? [1] : []
    content {
      publisher = coalesce(var.source_image_reference_publisher, "MicrosoftWindowsServer")
      offer     = coalesce(var.source_image_reference_offer, "WindowsServer")
      sku       = coalesce(var.source_image_reference_sku, "2016-Datacenter")
      version   = var.source_image_reference_version
    }
  }

  boot_diagnostics {
    storage_account_uri = var.boot_diagnostics ? join(",", azurerm_storage_account.vm-sa.*.primary_blob_endpoint) : ""
  }

  dynamic "additional_capabilities" {
    for_each = var.additional_capabilities
    content {
      ultra_ssd_enabled = additional_capabilities.value.ultra_ssd_enabled
    }
  }

  dynamic "additional_unattend_content" {
    for_each = var.additional_unattend_content
    content {
      content = additional_unattend_content.value.content
      setting = additional_unattend_content.value.setting
    }
  }

  dynamic "secret" {
    for_each = var.secret
    content {
      certificate {
        store = secret.value.store
        url   = secret.slue.url
      }
      key_vault_id = secret.value.key_vault_id
    }
  }

  dynamic "identity" {
    for_each = var.identity
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "plan" {
    for_each = var.plan
    content {
      name      = plan.value.name
      product   = plan.value.product
      publisher = plan.value.publisher
    }
  }

  dynamic "winrm_listener" {
    for_each = var.winrm_listener
    content {
      protocol        = winrm_listener.value.protocol
      certificate_url = winrm_listener.value.certificate_url
    }
  }
}

# Sending local metrics to Azure Monitor
# https://docs.microsoft.com/en-us/azure/azure-monitor/platform/collect-custom-metrics-guestos-resource-manager-vm
resource "azurerm_virtual_machine_extension" "win-msi" {
  count                      = var.is_windows && var.boot_diagnostics ? var.vm_count : 0
  name                       = format("%s-msi", element(azurerm_windows_virtual_machine.base.*.name, count.index))
  virtual_machine_id         = element(azurerm_windows_virtual_machine.base.*.id, count.index)
  publisher                  = "Microsoft.ManagedIdentity"
  type                       = "ManagedIdentityExtensionForWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
	{
		"port"            : "50342"
	}
	SETTINGS
  tags = merge(
    var.tags,
    { terraform = "true" }
  )
}

resource "azurerm_virtual_machine_extension" "win-metrics" {
  count                      = var.is_windows && var.boot_diagnostics ? var.vm_count : 0
  name                       = format("%s-metrics", element(azurerm_windows_virtual_machine.base.*.name, count.index))
  virtual_machine_id         = element(azurerm_windows_virtual_machine.base.*.id, count.index)
  publisher                  = "Microsoft.Azure.Diagnostics"
  type                       = "IaaSDiagnostics"
  type_handler_version       = "1.9"
  auto_upgrade_minor_version = true

  settings           = <<SETTINGS
	{
		"xmlCfg"            : "${base64encode(templatefile("${path.module}/diagnostics/wadcfg.xml", { resource_id = element(azurerm_windows_virtual_machine.base.*.id, count.index) }))}",
        "storageAccount"    : "${azurerm_storage_account.vm-sa.0.name}"
	}
	SETTINGS
  protected_settings = <<SETTINGS
	{
        "storageAccountName"     : "${azurerm_storage_account.vm-sa.0.name}",
		"storageAccountKey"      : "${azurerm_storage_account.vm-sa.0.primary_access_key}",
		"storageAccountEndpoint" : "${azurerm_storage_account.vm-sa.0.primary_blob_endpoint}"
	}
	SETTINGS
  tags = merge(
    var.tags,
    { terraform = "true" }
  )
  depends_on = [azurerm_virtual_machine_extension.win-msi]
}

resource "azurerm_virtual_machine_extension" "win-domain-join" {
  count = var.is_windows && var.join_domain ? var.vm_count : 0

  name                 = format("%s-domainjoin", element(azurerm_windows_virtual_machine.base.*.name, count.index))
  virtual_machine_id   = element(azurerm_windows_virtual_machine.base.*.id, count.index)
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"
  # What the settings mean: https://docs.microsoft.com/en-us/windows/desktop/api/lmjoin/nf-lmjoin-netjoindomain
  settings           = <<SETTINGS
    {
        "Name": "zurich.com",
        "User": "${format("gitdir\\\\%s", var.domain_join_user)}",
        "Restart": "true",
        "Options": "3"
    }
SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
    {
        "Password": "${var.domain_join_password}"
    }
PROTECTED_SETTINGS
  tags = merge(
    var.tags,
    { terraform = "true" }
  )
}