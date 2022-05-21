resource "azurerm_storage_account" "storage_account" {
  for_each                  = toset(var.locations)
  name                      = format("%s%s", var.storage_account_name_prefix, lookup(var.location_lookup, each.value))
  resource_group_name       = var.resource_group_name
  location                  = each.value
  account_replication_type  = var.account_replication_type
  account_kind              = var.account_kind
  account_tier              = var.account_tier
  enable_https_traffic_only = var.enable_https_traffic_only

  network_rules {
    bypass                     = ["AzureServices", "Logging", "Metrics"]
    default_action             = var.default_action
    virtual_network_subnet_ids = var.vnet_subnet_ids
    ip_rules                   = var.allowed_cidrs
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
      retention_policy_days = 90
    }
    minute_metrics {
      enabled               = true
      version               = "1.0"
      include_apis          = true
      retention_policy_days = 7
    }
  }

  lifecycle {
    ignore_changes = [account_kind, tags] # Need to ignore tags as cloudshell adds its own "ms-resource-usage"
  }

  tags = merge(
    var.tags,
    { terraform = "true" }
  )
}
