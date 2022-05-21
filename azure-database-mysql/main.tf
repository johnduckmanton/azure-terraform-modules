locals {
  admin_username = var.admin_username == "" ? random_string.username.id : var.admin_username
  password       = var.password == "" ? random_string.password.result : var.password
  location       = lower(var.location)
}

resource "azurerm_mysql_server" "server" {
  name                              = var.name
  location                          = local.location
  resource_group_name               = var.resource_group_name
  sku_name                          = var.sku_name
  storage_mb                        = var.storage_mb
  backup_retention_days             = var.backup_retention_days
  geo_redundant_backup_enabled      = var.geo_redundant_backup_enabled
  auto_grow_enabled                 = var.auto_grow_enabled
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled
  create_mode                       = var.create_mode
  creation_source_server_id         = var.creation_source_server_id
  public_network_access_enabled     = var.public_network_access_enabled
  administrator_login               = local.admin_username
  administrator_login_password      = local.password
  version                           = var.db_version
  ssl_enforcement_enabled           = var.ssl_enforcement_enabled
  ssl_minimal_tls_version_enforced  = var.ssl_minimal_tls_version_enforced
  restore_point_in_time             = var.restore_point_in_time
  tags = merge(
    var.tags,
    { terraform = "true" }
  )
}

resource "azurerm_mysql_database" "database" {
  for_each = var.dbs

  name                = each.key
  charset             = lookup(each.value, "charset", var.charset)
  collation           = lookup(each.value, "collation", var.collation)
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.server.name
}

resource "azurerm_mysql_firewall_rule" "firewall_rule" {
  for_each = var.public_network_access_enabled && length(var.firewall_rules) > 0 ? var.firewall_rules : {}

  name                = each.key
  start_ip_address    = each.value.start_ip
  end_ip_address      = each.value.end_ip
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.server.name
}

resource "azurerm_mysql_virtual_network_rule" "vnet_rule" {
  for_each = var.vnet_rules

  name                = each.key
  subnet_id           = each.value
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.server.name
}

resource "azurerm_mysql_configuration" "config" {
  for_each = var.mysql_configurations

  name                = each.key
  value               = each.value
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.server.name
}

resource "random_string" "password" {
  length           = 22
  special          = true
  min_special      = 1
  min_numeric      = 1
  min_lower        = 1
  min_upper        = 1
  override_special = "!$&-<=>?_|~"
}

resource "random_string" "username" {
  length  = 6
  special = false
  number  = false
}

