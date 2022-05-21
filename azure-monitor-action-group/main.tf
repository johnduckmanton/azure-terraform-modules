resource "azurerm_monitor_action_group" "action_group" {
  name                = var.name
  resource_group_name = var.rg_name
  short_name          = var.short_name

  dynamic "email_receiver" {
    for_each = length(var.actiongroup_email) > 0 ? [1] : []
    content {
      email_address = var.actiongroup_email
      name          = var.actiongroup_name
    }
  }

  dynamic "webhook_receiver" {
    for_each = length(var.webhook_uri) > 0 ? [1] : []
    content {
      name        = var.webhook_name
      service_uri = var.webhook_uri
    }
  }

  tags = merge(
    var.tags,
    { terraform = "true" }
  )
}
