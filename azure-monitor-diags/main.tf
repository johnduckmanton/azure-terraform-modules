resource "azurerm_monitor_diagnostic_setting" "monitor" {
  name                           = "activity-logs-diags"
  target_resource_id             = var.subscription_id
  eventhub_name                  = var.event_hub_name
  eventhub_authorization_rule_id = data.azurerm_eventhub_namespace_authorization_rule.hub.id

  dynamic "log" {
    iterator = log_category
    for_each = var.log_categories

    content {
      category = log_category.value
      enabled  = true

      dynamic "retention_policy" {
        for_each = var.require_retention ? [1] : []
        content {
          enabled = true
          days    = var.retention_days
        }
      }
    }
  }
}

data "azurerm_eventhub_namespace_authorization_rule" "hub" {
  name                = var.auth_name
  namespace_name      = var.auth_namespace_name
  resource_group_name = var.auth_resource_group_name
}