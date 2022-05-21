locals {
  vm_name = format("M%s%s%s%s%s", lookup(var.global_region_lookup, local.location, "E"),
    lookup(var.cloud_region_lookup, local.location, "I"), lookup(var.environment_lookup, local.environment, "X"),
  var.is_windows ? "W" : "L", lookup(var.purpose_lookup, local.purpose, "AP"))
  location       = lower(var.location)
  environment    = lower(var.environment)
  purpose        = lower(var.vm_purpose)
  admin_username = var.admin_username == "" ? random_string.username.id : var.admin_username
  admin_password = var.admin_password == "" ? random_string.password.result : var.admin_password
  is_linux       = var.is_windows ? false : true
}

resource "random_id" "vm-sa" {
  keepers = {
    vm_name = local.vm_name
  }

  byte_length = 6
}

resource "azurerm_storage_account" "vm-sa" {
  count                     = var.boot_diagnostics ? 1 : 0
  name                      = "bootdiag${lower(random_id.vm-sa.hex)}"
  resource_group_name       = var.resource_group_name
  location                  = local.location
  account_replication_type  = "LRS"
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  access_tier               = "Hot"
  enable_https_traffic_only = true

  network_rules {
    bypass         = ["AzureServices", "Logging", "Metrics"]
    default_action = "Allow"
  }

  queue_properties {
    hour_metrics {
      enabled               = true
      version               = "1.0"
      include_apis          = true
      retention_policy_days = 7
    }
    logging {
      delete                = true
      read                  = true
      version               = "1.0"
      write                 = true
      retention_policy_days = 91
    }
    minute_metrics {
      enabled               = true
      version               = "1.0"
      include_apis          = true
      retention_policy_days = 7
    }
  }

  lifecycle {
    ignore_changes = [account_kind]
  }

  tags = merge(
    var.tags,
    { terraform = "true" }
  )
}

resource "azurerm_availability_set" "vm" {
  name                         = format("%s%04dX-avset", local.vm_name, var.vm_init_number)
  resource_group_name          = var.resource_group_name
  location                     = local.location
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
  tags = merge(
    var.tags,
    { terraform = "true" }
  )
}

resource "azurerm_public_ip" "vm" {
  count               = var.count_public_ip * var.vm_count
  name                = format("%s%05d-pip%s", local.vm_name, var.vm_init_number + count.index, count.index)
  resource_group_name = var.resource_group_name
  location            = local.location
  allocation_method   = var.allocation_method
  domain_name_label   = element(var.public_ip_dns, count.index)
  tags = merge(
    var.tags,
    { terraform = "true" }
  )
}

resource "azurerm_network_interface" "vm" {
  count                         = var.vm_count
  name                          = format("%s%05d-nic%s", local.vm_name, var.vm_init_number + count.index, count.index)
  resource_group_name           = var.resource_group_name
  location                      = local.location
  enable_accelerated_networking = var.enable_accelerated_networking

  ip_configuration {
    name                          = format("%s%05d-ip%s", local.vm_name, var.vm_init_number + count.index, count.index)
    subnet_id                     = var.vnet_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = length(azurerm_public_ip.vm.*.id) > 0 ? element(concat(azurerm_public_ip.vm.*.id, list("")), count.index) : ""
  }

  tags = merge(
    var.tags,
    { terraform = "true" }
  )
}

resource "random_string" "password" {
  length           = 22
  special          = true
  min_special      = 1
  min_numeric      = 1
  min_lower        = 1
  min_upper        = 1
  override_special = "!$&-<=>?_|~"
}

resource "random_string" "username" {
  length  = 12
  special = false
  number  = false
}