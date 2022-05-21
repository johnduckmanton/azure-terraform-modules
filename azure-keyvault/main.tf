resource "azurerm_key_vault" "keyvault" {
  location                        = var.location
  name                            = format("%s%d", var.name, var.kv_number)
  resource_group_name             = var.rg_name
  tenant_id                       = var.tenant_id
  sku_name                        = "premium"
  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  soft_delete_enabled             = true
  purge_protection_enabled        = var.enable_purge_protection

  network_acls {
    bypass                     = "AzureServices"
    default_action             = var.public ? "Allow" : "Deny"
    virtual_network_subnet_ids = var.vnet_subnet_ids
    ip_rules                   = var.proxy_cidrs
  }
  tags = merge(
    var.tags,
    { terraform = "true" }
  )
}
