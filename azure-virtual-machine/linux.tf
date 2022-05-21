resource "azurerm_linux_virtual_machine" "base" {
  count = var.is_windows ? 0 : var.vm_count

  name                            = format("%s%05d", local.vm_name, var.vm_init_number + count.index)
  resource_group_name             = var.resource_group_name
  location                        = local.location
  size                            = var.size
  admin_username                  = local.admin_username
  admin_password                  = local.admin_password
  disable_password_authentication = var.disable_password_authentication
  network_interface_ids           = [element(azurerm_network_interface.vm.*.id, count.index)]
  allow_extension_operations      = var.allow_extension_operations
  availability_set_id             = azurerm_availability_set.vm.id
  computer_name                   = format("%s%05d", local.vm_name, var.vm_init_number + count.index)
  custom_data                     = var.custom_data
  dedicated_host_id               = var.dedicated_host_id
  eviction_policy                 = var.eviction_policy
  max_bid_price                   = var.max_bid_price
  priority                        = var.priority
  provision_vm_agent              = var.provision_vm_agent
  proximity_placement_group_id    = var.proximity_placement_group_id
  source_image_id                 = var.source_image_id
  tags = merge(
    var.tags,
    { terraform = "true" }
  )

  dynamic "admin_ssh_key" {
    for_each = var.enable_ssh_key ? [var.admin_ssh_key_public_key] : []
    content {
      public_key = var.admin_ssh_key_public_key
      username   = local.admin_username
    }
  }

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
      publisher = coalesce(var.source_image_reference_publisher, "RedHat")
      offer     = coalesce(var.source_image_reference_offer, "RHEL")
      sku       = coalesce(var.source_image_reference_sku, "7.7")
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

  dynamic "secret" {
    for_each = var.secret
    content {
      certificate {
        url = secret.value.url
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
}

resource "azurerm_virtual_machine_extension" "telegraf" {
  count                = var.boot_diagnostics ? length(azurerm_linux_virtual_machine.base.*.name) : 0
  name                 = format("%s-telegraf", element(azurerm_linux_virtual_machine.base.*.name, count.index))
  virtual_machine_id   = element(azurerm_linux_virtual_machine.base.*.id, count.index)
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  protected_settings = <<PROT
    {
        "script": "${base64encode(file("${path.module}/diagnostics/telegraf_install.bash"))}"
    }
    PROT

  tags = merge(
    var.tags,
    { terraform = "true" }
  )
}
