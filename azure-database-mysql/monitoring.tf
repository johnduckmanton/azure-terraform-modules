resource "azurerm_monitor_metric_alert" "cpu" {
  count               = var.alerts_enabled == true ? 1 : 0
  name                = format("mysql-%s-cpu", azurerm_mysql_server.server.name)
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_mysql_server.server.id]
  description         = format("%s - Average CPU percent used is greater than %s percent for more than 5 minutes", azurerm_mysql_server.server.name, var.alert_cpu)
  window_size         = "PT5M"
  criteria {
    aggregation      = "Average"
    metric_name      = "cpu_percent"
    metric_namespace = "Microsoft.DBforMySQL/servers"
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

resource "azurerm_monitor_metric_alert" "memory" {
  count               = var.alerts_enabled == true ? 1 : 0
  name                = format("mysql-%s-memory", azurerm_mysql_server.server.name)
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_mysql_server.server.id]
  description         = format("%s - Average memory percent used is greater than %s percent for more than 5 minutes", azurerm_mysql_server.server.name, var.alert_memory)
  window_size         = "PT5M"
  criteria {
    aggregation      = "Average"
    metric_name      = "memory_percent"
    metric_namespace = "Microsoft.DBforMySQL/servers"
    operator         = "GreaterThan"
    threshold        = var.alert_memory
  }
  action {
    action_group_id = var.action_group_id
  }
  tags = merge(
    var.tags,
    { terraform = "true" }
  )
}

resource "azurerm_monitor_metric_alert" "storage" {
  count               = var.alerts_enabled == true ? 1 : 0
  name                = format("mysql-%s-storage", azurerm_mysql_server.server.name)
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_mysql_server.server.id]
  description         = format("%s - Average storage percent used is greater than %s percent for more than 5 minutes", azurerm_mysql_server.server.name, var.alert_storage)
  window_size         = "PT5M"
  criteria {
    aggregation      = "Average"
    metric_name      = "storage_percent"
    metric_namespace = "Microsoft.DBforMySQL/servers"
    operator         = "GreaterThan"
    threshold        = var.alert_storage
  }
  action {
    action_group_id = var.action_group_id
  }
  tags = merge(
    var.tags,
    { terraform = "true" }
  )
}

resource "azurerm_monitor_metric_alert" "log-storage" {
  count               = var.alerts_enabled == true ? 1 : 0
  name                = format("mysql-%s-log-storage", azurerm_mysql_server.server.name)
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_mysql_server.server.id]
  description         = format("%s - Average log storage percent used is greater than %s percent for more than 5 minutes", azurerm_mysql_server.server.name, var.alert_log_storage)
  window_size         = "PT5M"
  criteria {
    aggregation      = "Average"
    metric_name      = "serverlog_storage_percent"
    metric_namespace = "Microsoft.DBforMySQL/servers"
    operator         = "GreaterThan"
    threshold        = var.alert_log_storage
  }
  action {
    action_group_id = var.action_group_id
  }
  tags = merge(
    var.tags,
    { terraform = "true" }
  )
}

resource "azurerm_monitor_metric_alert" "failed-connections" {
  count               = var.alerts_enabled == true ? 1 : 0
  name                = format("mysql-%s-failed-connections", azurerm_mysql_server.server.name)
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_mysql_server.server.id]
  description         = format("%s - Average failed connections is greater than %s in the last 5 minutes", azurerm_mysql_server.server.name, var.alert_failed_connections)
  window_size         = "PT5M"
  criteria {
    aggregation      = "Total"
    metric_name      = "connections_failed"
    metric_namespace = "Microsoft.DBforMySQL/servers"
    operator         = "GreaterThan"
    threshold        = var.alert_failed_connections
  }
  action {
    action_group_id = var.action_group_id
  }
  tags = merge(
    var.tags,
    { terraform = "true" }
  )
}

resource "azurerm_monitor_activity_log_alert" "health" {
  count               = var.alerts_enabled == true ? 1 : 0
  name                = format("mysql-%s-health", azurerm_mysql_server.server.name)
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_mysql_server.server.id]
  description         = format("%s - health alert triggered", azurerm_mysql_server.server.name)
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