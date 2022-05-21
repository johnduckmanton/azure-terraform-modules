resource "azurerm_storage_account" "storage_account" {
  name                      = var.storage_account_name
  resource_group_name       = var.resource_group_name
  location                  = var.location
  account_replication_type  = var.account_replication_type
  account_kind              = var.account_kind
  account_tier              = var.account_tier
  access_tier               = var.access_tier
  is_hns_enabled            = var.is_hns_enabled
  enable_https_traffic_only = var.enable_https_traffic_only

  network_rules {
    bypass                     = var.network_bypass
    default_action             = var.default_action
    virtual_network_subnet_ids = var.vnet_subnet_ids
    ip_rules                   = var.allowed_cidrs
  }

  queue_properties {
    hour_metrics {
      enabled               = var.enable_queue_logging
      version               = var.queue_metric_version
      include_apis          = var.enable_queue_logging
      retention_policy_days = var.queue_hour_metric_retention
    }
    logging {
      delete                = var.enable_queue_logging
      read                  = var.enable_queue_logging
      version               = var.queue_metric_version
      write                 = var.enable_queue_logging
      retention_policy_days = var.queue_logging_retention
    }
    minute_metrics {
      enabled               = var.enable_queue_logging
      version               = var.queue_metric_version
      include_apis          = var.enable_queue_logging
      retention_policy_days = var.queue_minute_metric_retention
    }
  }

  lifecycle {
    ignore_changes = [account_kind, tags["ms-resource-usage"]] # Need to ignore cloud shell tag
  }

  tags = merge(
    var.tags,
    { terraform = "true" }
  )
}

resource "azurerm_storage_container" "container" {
  name                  = var.container_names[count.index]
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = var.container_access_type
  count                 = length(var.container_names)
}

resource "azurerm_storage_table" "table" {
  name                 = var.table_names[count.index]
  storage_account_name = azurerm_storage_account.storage_account.name
  count                = length(var.table_names)
}

resource "azurerm_storage_share" "share" {
  name                 = var.share_names[count.index]
  storage_account_name = azurerm_storage_account.storage_account.name
  quota                = var.quota
  count                = length(var.share_names)
}