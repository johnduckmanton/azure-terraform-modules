resource "azurerm_monitor_activity_log_alert" "health" {
  count               = var.alerts_enabled ? 1 : 0
  name                = format("appgw-%s-health", azurerm_application_gateway.main.name)
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_gateway.main.id]
  description         = format("%s - health alert triggered", azurerm_application_gateway.main.name)
  criteria {
    resource_type = "Microsoft.Insights/activityLogAlerts"
    status        = "Active"
    category      = "ResourceHealth"
  }
  action {
    action_group_id = var.action_group_id
  }
  tags = merge(
    var.tags,
    { terraform = "true" }
  )
}

resource "azurerm_monitor_metric_alert" "cpu" {
  count               = var.alerts_enabled ? 1 : 0
  name                = format("appgw-%s-cpu", azurerm_application_gateway.main.name)
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_gateway.main.id]
  description         = format("%s - Average CPU percent used is greater than %s percent for more than 5 minutes", azurerm_application_gateway.main.name, var.alert_cpu)
  window_size         = "PT5M"
  criteria {
    aggregation      = "Average"
    metric_name      = "CpuUtilization"
    metric_namespace = "Microsoft.Network/applicationGateways"
    operator         = "GreaterThan"
    threshold        = var.alert_cpu
  }
  action {
    action_group_id = var.action_group_id
  }
  tags = merge(
    var.tags,
    { terraform = "true" }
  )
}

resource "azurerm_monitor_metric_alert" "failed_requests" {
  count               = var.alerts_enabled ? 1 : 0
  name                = format("appgw-%s-failed-requests", azurerm_application_gateway.main.name)
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_gateway.main.id]
  description         = format("%s - Total failed requests is greater than %s for more than 5 minutes", azurerm_application_gateway.main.name, var.alert_failed_requests)
  window_size         = "PT5M"
  criteria {
    aggregation      = "Total"
    metric_name      = "FailedRequests"
    metric_namespace = "Microsoft.Network/applicationGateways"
    operator         = "GreaterThan"
    threshold        = var.alert_failed_requests
  }
  action {
    action_group_id = var.action_group_id
  }
  tags = merge(
    var.tags,
    { terraform = "true" }
  )
}

resource "azurerm_monitor_metric_alert" "unhealthy_hosts" {
  count               = var.alerts_enabled ? 1 : 0
  name                = format("appgw-%s-unhealthy-hosts", azurerm_application_gateway.main.name)
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_gateway.main.id]
  description         = format("%s - Average unhealthy hosts is greater than %s for more than 5 minutes", azurerm_application_gateway.main.name, var.alert_unhealthy_hosts)
  window_size         = "PT5M"
  criteria {
    aggregation      = "Average"
    metric_name      = "UnhealthyHostCount"
    metric_namespace = "Microsoft.Network/applicationGateways"
    operator         = "GreaterThan"
    threshold        = var.alert_unhealthy_hosts
  }
  action {
    action_group_id = var.action_group_id
  }
  tags = merge(
    var.tags,
    { terraform = "true" }
  )
}