resource "azurerm_monitor_metric_alert" "cpu" {
  count               = var.alerts_enabled == true ? var.vm_count : 0
  name                = format("vms-%s%05d-cpu", local.vm_name, var.vm_init_number + count.index)
  resource_group_name = var.resource_group_name
  scopes              = var.is_windows ? [azurerm_windows_virtual_machine.base[count.index].id] : [azurerm_linux_virtual_machine.base[count.index].id]
  description         = format("%s - Average CPU percent used is greater than %s percent for more than 5 minutes", format("%s%05d", local.vm_name, var.vm_init_number + count.index), var.alert_cpu)
  window_size         = "PT5M"
  criteria {
    aggregation      = "Average"
    metric_name      = "Percentage CPU"
    metric_namespace = "Microsoft.Compute/virtualMachines"
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

resource "time_sleep" "metric_wait_win" {
  count           = var.alerts_enabled && var.is_windows ? 1 : 0
  create_duration = "20m"
  depends_on      = [azurerm_virtual_machine_extension.win-metrics]
}

resource "azurerm_monitor_metric_alert" "windows_storage" {
  count               = var.alerts_enabled && var.is_windows ? var.vm_count : 0
  name                = format("vms-%s%05d-storage", local.vm_name, var.vm_init_number + count.index)
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_windows_virtual_machine.base[count.index].id]
  description         = format("%s - Disk space is below %s percent", format("%s%05d", local.vm_name, var.vm_init_number + count.index), var.alert_storage)
  window_size         = "PT5M"
  criteria {
    aggregation      = "Average"
    metric_name      = "LogicalDisk\\% Free Space"
    metric_namespace = "azure.vm.windows.guestmetrics"
    operator         = "LessThan"
    threshold        = var.alert_storage
  }
  action {
    action_group_id = var.action_group_id
  }
  tags = merge(
    var.tags,
    { terraform = "true" }
  )
  depends_on = [azurerm_virtual_machine_extension.win-metrics, time_sleep.metric_wait_win]
}

resource "azurerm_monitor_metric_alert" "windows_memory" {
  count               = var.alerts_enabled && var.is_windows ? var.vm_count : 0
  name                = format("vms-%s%05d-memory", local.vm_name, var.vm_init_number + count.index)
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_windows_virtual_machine.base[count.index].id]
  description         = format("%s - Memory usage is over %s percent for the last 5 minutes", format("%s%05d", local.vm_name, var.vm_init_number + count.index), var.alert_memory)
  window_size         = "PT5M"
  criteria {
    aggregation      = "Average"
    metric_name      = "Memory\\% Committed Bytes In Use"
    metric_namespace = "azure.vm.windows.guestmetrics"
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
  depends_on = [azurerm_virtual_machine_extension.win-metrics, time_sleep.metric_wait_win]
}

resource "azurerm_monitor_activity_log_alert" "health" {
  count               = var.alerts_enabled == true ? var.vm_count : 0
  name                = format("vms-%s%05d-health", local.vm_name, var.vm_init_number + count.index)
  resource_group_name = var.resource_group_name
  scopes              = var.is_windows ? [azurerm_windows_virtual_machine.base[count.index].id] : [azurerm_linux_virtual_machine.base[count.index].id]
  description         = format("%s - Health alert triggered", format("%s%05d", local.vm_name, var.vm_init_number + count.index))
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

resource "time_sleep" "metric_wait_linux" {
  count           = var.alerts_enabled && local.is_linux ? 1 : 0
  create_duration = "120s"
  depends_on      = [azurerm_virtual_machine_extension.telegraf]
}

resource "azurerm_monitor_metric_alert" "linux_storage" {
  count               = var.alerts_enabled && local.is_linux ? var.vm_count : 0
  name                = format("vms-%s%05d-storage", local.vm_name, var.vm_init_number + count.index)
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_linux_virtual_machine.base[count.index].id]
  description         = format("%s - Disk space is below %s percent", format("%s%05d", local.vm_name, var.vm_init_number + count.index), var.alert_storage)
  window_size         = "PT5M"
  criteria {
    aggregation      = "Average"
    metric_name      = "used_percent"
    metric_namespace = "telegraf/disk"
    operator         = "GreaterThan"
    threshold        = 100 - var.alert_storage
  }
  action {
    action_group_id = var.action_group_id
  }
  tags = merge(
    var.tags,
    { terraform = "true" }
  )
  depends_on = [azurerm_virtual_machine_extension.telegraf, time_sleep.metric_wait_linux]
}

resource "azurerm_monitor_metric_alert" "linux_memory" {
  count               = var.alerts_enabled && local.is_linux ? var.vm_count : 0
  name                = format("vms-%s%05d-memory", local.vm_name, var.vm_init_number + count.index)
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_linux_virtual_machine.base[count.index].id]
  description         = format("%s - Memory usage is over %s percent for the last 5 minutes", format("%s%05d", local.vm_name, var.vm_init_number + count.index), var.alert_memory)
  window_size         = "PT5M"
  criteria {
    aggregation      = "Average"
    metric_name      = "used_percent"
    metric_namespace = "telegraf/mem"
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
  depends_on = [azurerm_virtual_machine_extension.telegraf, time_sleep.metric_wait_linux]
}