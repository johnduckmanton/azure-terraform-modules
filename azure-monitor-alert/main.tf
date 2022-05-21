resource "azurerm_monitor_activity_log_alert" "alert" {
  name                = var.name[count.index]
  resource_group_name = var.rg_name
  scopes              = [var.scope]
  description         = var.description

  criteria {
    category       = var.category
    operation_name = var.operation_name[count.index]
    resource_type  = var.resource_type[count.index]
    caller         = var.caller[count.index]
    status         = var.criteria_status
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = merge(
    var.tags,
    { terraform = "true" }
  )
  count = length(var.name)
}

resource "azurerm_management_lock" "lock" {
  lock_level = "CanNotDelete"
  name       = format("%s-lock", var.name[count.index])
  scope      = azurerm_monitor_activity_log_alert.alert[count.index].id
  notes      = "Securing Alerts resources"
  count      = length(var.name)
}