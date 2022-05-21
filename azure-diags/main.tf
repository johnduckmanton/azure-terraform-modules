resource "azurerm_monitor_diagnostic_setting" "monitor" {
  name                           = format("%s-diags", var.name_prefix)
  target_resource_id             = var.resource_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = var.log_analytics_workspace_id == "" ? null : var.log_analytics_destination_type
  storage_account_id             = var.storage_account_id
  eventhub_name                  = var.eventhub_name

  dynamic "log" {
    iterator = log_category
    for_each = var.log_categories

    content {
      category = log_category.value
      enabled  = true

      retention_policy {
        enabled = true
        days    = var.log_retention_days
      }
    }
  }

  dynamic "metric" {
    iterator = metric_category
    for_each = var.metric_categories

    content {
      category = metric_category.value
      enabled  = true

      retention_policy {
        enabled = true
        days    = var.log_retention_days
      }
    }
  }
}
