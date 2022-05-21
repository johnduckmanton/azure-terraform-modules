resource "azurerm_log_analytics_workspace" "loganalytics" {
  location            = var.location
  name                = var.name
  resource_group_name = var.rg_name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_in_days
  tags                = var.tags
}
