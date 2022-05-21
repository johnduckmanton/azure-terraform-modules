locals {
  administrator_login          = var.administrator_login == "" ? random_string.username.id : var.administrator_login
  administrator_login_password = var.administrator_login_password == "" ? random_string.password.result : var.administrator_login_password
  location                     = lower(var.location)
}

resource "azurerm_storage_account" "storage" {
  count                     = var.extended_auditing_enabled ? 1 : 0
  name                      = format("%seasa", var.server_name)
  resource_group_name       = var.resource_group_name
  location                  = var.location
  account_replication_type  = "LRS"
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  access_tier               = "Hot"
  enable_https_traffic_only = true

  network_rules {
    bypass         = ["AzureServices", "Logging", "Metrics"]
    default_action = "Allow"
    ip_rules       = var.storage_allowed_cidrs
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

resource "azurerm_mssql_server" "server" {
  name                          = var.server_name
  resource_group_name           = var.resource_group_name
  location                      = local.location
  version                       = var.server_version
  administrator_login           = local.administrator_login
  administrator_login_password  = local.administrator_login_password
  public_network_access_enabled = var.public_network_access_enabled
  connection_policy             = var.connection_policy

  dynamic "extended_auditing_policy" {
    for_each = var.extended_auditing_enabled == true ? var.foreach_config : {}

    content {
      storage_endpoint                        = azurerm_storage_account.storage[0].primary_blob_endpoint
      storage_account_access_key              = azurerm_storage_account.storage[0].secondary_access_key
      storage_account_access_key_is_secondary = true
      retention_in_days                       = var.retention_in_days
    }
  }

  dynamic "azuread_administrator" {
    for_each = var.azuread_administrator_enabled == true ? var.foreach_config : {}
    content {
      login_username = var.aad_login_username
      object_id      = var.aad_object_id
    }
  }

  dynamic "identity" {
    for_each = var.server_identity_enabled == true ? var.foreach_config : {}
    content {
      type = "SystemAssigned"
    }
  }

  tags = merge(
    var.tags,
    { terraform = "true" }
  )
}

resource "azurerm_mssql_server_security_alert_policy" "policy" {
  count                      = var.extended_auditing_enabled == true ? 1 : 0
  resource_group_name        = var.resource_group_name
  server_name                = azurerm_mssql_server.server.name
  state                      = "Enabled"
  email_account_admins       = true
  email_addresses            = var.notification_email_addresses
  retention_days             = var.retention_in_days
  storage_endpoint           = azurerm_storage_account.storage[0].primary_blob_endpoint
  storage_account_access_key = azurerm_storage_account.storage[0].secondary_access_key
}

resource "azurerm_mssql_database" "database" {
  for_each                    = var.dbs
  name                        = each.key
  server_id                   = azurerm_mssql_server.server.id
  collation                   = lookup(each.value, "collation", "SQL_Latin1_General_CP1_CI_AS")
  license_type                = lookup(each.value, "license_type", "LicenseIncluded")
  max_size_gb                 = lookup(each.value, "max_size_gb", 100)
  create_mode                 = lookup(each.value, "create_mode", null)
  creation_source_database_id = lookup(each.value, "creation_source_database_id", null)
  restore_point_in_time       = lookup(each.value, "restore_point_in_time", null)
  read_scale                  = lookup(each.value, "read_scale", true)
  read_replica_count          = lookup(each.value, "read_replica_count", null)
  sku_name                    = lookup(each.value, "read_replica_count", "BC_Gen5_2")
  zone_redundant              = lookup(each.value, "read_replica_count", false)

  dynamic "extended_auditing_policy" {
    for_each = var.extended_auditing_enabled == true ? var.dbs : {}
    content {
      storage_endpoint                        = azurerm_storage_account.storage[0].primary_blob_endpoint
      storage_account_access_key              = azurerm_storage_account.storage[0].secondary_access_key
      storage_account_access_key_is_secondary = true
      retention_in_days                       = var.retention_in_days
    }
  }

  dynamic "threat_detection_policy" {
    for_each = var.threat_detection_policy_enabled && var.extended_auditing_enabled == true ? var.dbs : {}
    content {
      state                      = "Enabled"
      email_account_admins       = "Enabled"
      email_addresses            = var.notification_email_addresses
      retention_days             = var.retention_in_days
      storage_endpoint           = azurerm_storage_account.storage[0].primary_blob_endpoint
      storage_account_access_key = azurerm_storage_account.storage[0].secondary_access_key
      use_server_default         = "Disabled"
    }
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
  length  = 6
  special = false
  number  = false
}
