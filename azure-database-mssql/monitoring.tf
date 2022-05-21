resource "azurerm_monitor_activity_log_alert" "server_health" {
  count               = var.alerts_enabled == true ? 1 : 0
  name                = format("mssql-%s-health", azurerm_mssql_server.server.name)
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_mssql_server.server.id]
  description         = format("%s - health alert triggered", azurerm_mssql_server.server.name)
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

resource "azurerm_monitor_activity_log_alert" "database_health" {
  for_each            = var.alerts_enabled == true ? var.dbs : {}
  name                = format("mssqldb-%s-health", azurerm_mssql_database.database[each.key].name)
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_mssql_database.database[each.key].id]
  description         = format("%s - health alert triggered", azurerm_mssql_database.database[each.key].name)
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
  for_each            = var.alerts_enabled == true ? var.dbs : {}
  name                = format("mssqldb-%s-cpu", azurerm_mssql_database.database[each.key].name)
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_mssql_database.database[each.key].id]
  description         = format("%s - Average CPU percent used is greater than %s percent for more than 5 minutes", azurerm_mssql_database.database[each.key].name, var.alert_cpu)
  window_size         = "PT5M"
  criteria {
    aggregation      = "Average"
    metric_name      = "cpu_percent"
    metric_namespace = "Microsoft.Sql/servers/databases"
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

resource "azurerm_monitor_metric_alert" "dataread" {
  for_each            = var.alerts_enabled == true ? var.dbs : {}
  name                = format("mssqldb-%s-dataread", azurerm_mssql_database.database[each.key].name)
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_mssql_database.database[each.key].id]
  description         = format("%s - Average physical data read percent used is greater than %s percent for more than 5 minutes", azurerm_mssql_database.database[each.key].name, var.alert_dataread)
  window_size         = "PT5M"
  criteria {
    aggregation      = "Average"
    metric_name      = "physical_data_read_percent"
    metric_namespace = "Microsoft.Sql/servers/databases"
    operator         = "GreaterThan"
    threshold        = var.alert_dataread
  }
  action {
    action_group_id = var.action_group_id
  }
  tags = merge(
    var.tags,
    { terraform = "true" }
  )
}

resource "azurerm_monitor_metric_alert" "failedconnections" {
  for_each            = var.alerts_enabled == true ? var.dbs : {}
  name                = format("mssqldb-%s-failedconnections", azurerm_mssql_database.database[each.key].name)
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_mssql_database.database[each.key].id]
  description         = format("%s - Average failed connections is greater than %s in the last 5 minutes", azurerm_mssql_database.database[each.key].name, var.alert_failed_connections)
  window_size         = "PT5M"
  criteria {
    aggregation      = "Total"
    metric_name      = "connection_failed"
    metric_namespace = "Microsoft.Sql/servers/databases"
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

resource "azurerm_monitor_metric_alert" "storage" {
  for_each            = var.alerts_enabled == true ? var.dbs : {}
  name                = format("mssqldb-%s-storage", azurerm_mssql_database.database[each.key].name)
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_mssql_database.database[each.key].id]
  description         = format("%s - Average storage usage is greater than %s percent for more than 5 minutes", azurerm_mssql_database.database[each.key].name, var.alert_storage)
  window_size         = "PT5M"
  criteria {
    aggregation      = "Maximum"
    metric_name      = "storage_percent"
    metric_namespace = "Microsoft.Sql/servers/databases"
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

resource "azurerm_monitor_metric_alert" "sessions" {
  for_each            = var.alerts_enabled == true ? var.dbs : {}
  name                = format("mssqldb-%s-sessions", azurerm_mssql_database.database[each.key].name)
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_mssql_database.database[each.key].id]
  description         = format("%s - Average sessions is greater than %s percent for more than 5 minutes", azurerm_mssql_database.database[each.key].name, var.alert_sessions)
  window_size         = "PT5M"
  criteria {
    aggregation      = "Average"
    metric_name      = "sessions_percent"
    metric_namespace = "Microsoft.Sql/servers/databases"
    operator         = "GreaterThan"
    threshold        = var.alert_sessions
  }
  action {
    action_group_id = var.action_group_id
  }
  tags = merge(
    var.tags,
    { terraform = "true" }
  )
}

resource "azurerm_monitor_metric_alert" "core_cpu" {
  for_each            = var.alerts_enabled == true ? var.dbs : {}
  name                = format("mssqldb-%s-corecpu", azurerm_mssql_database.database[each.key].name)
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_mssql_database.database[each.key].id]
  description         = format("%s - Core CPU usage is greater than %s percent for more than 5 minutes", azurerm_mssql_database.database[each.key].name, var.alert_core_cpu)
  window_size         = "PT5M"
  criteria {
    aggregation      = "Maximum"
    metric_name      = "sqlserver_process_core_percent"
    metric_namespace = "Microsoft.Sql/servers/databases"
    operator         = "GreaterThan"
    threshold        = var.alert_core_cpu
  }
  action {
    action_group_id = var.action_group_id
  }
  tags = merge(
    var.tags,
    { terraform = "true" }
  )
}

resource "azurerm_monitor_metric_alert" "core_memory" {
  for_each            = var.alerts_enabled == true ? var.dbs : {}
  name                = format("mssqldb-%s-corememory", azurerm_mssql_database.database[each.key].name)
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_mssql_database.database[each.key].id]
  description         = format("%s - Core memory usage is greater than %s percent for more than 5 minutes", azurerm_mssql_database.database[each.key].name, var.alert_core_memory)
  window_size         = "PT5M"
  criteria {
    aggregation      = "Maximum"
    metric_name      = "sqlserver_process_memory_percent"
    metric_namespace = "Microsoft.Sql/servers/databases"
    operator         = "GreaterThan"
    threshold        = var.alert_core_memory
  }
  action {
    action_group_id = var.action_group_id
  }
  tags = merge(
    var.tags,
    { terraform = "true" }
  )
}

resource "azurerm_monitor_metric_alert" "tempdb_log" {
  for_each            = var.alerts_enabled == true ? var.dbs : {}
  name                = format("mssqldb-%s-tempdblog", azurerm_mssql_database.database[each.key].name)
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_mssql_database.database[each.key].id]
  description         = format("%s - Tempdb log usage is greater than %s percent for more than 5 minutes", azurerm_mssql_database.database[each.key].name, var.alert_tempdblog)
  window_size         = "PT5M"
  criteria {
    aggregation      = "Maximum"
    metric_name      = "tempdb_log_used_percent"
    metric_namespace = "Microsoft.Sql/servers/databases"
    operator         = "GreaterThan"
    threshold        = var.alert_tempdblog
  }
  action {
    action_group_id = var.action_group_id
  }
  tags = merge(
    var.tags,
    { terraform = "true" }
  )
}
