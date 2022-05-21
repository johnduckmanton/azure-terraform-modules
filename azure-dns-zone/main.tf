resource "azurerm_dns_zone" "zone" {
  name                = var.domain_name
  resource_group_name = var.rg_name
  tags                = var.tags
}