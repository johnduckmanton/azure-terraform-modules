resource "azurerm_key_vault_key" "generated" {
  name         = var.key_name
  key_vault_id = var.kv_id
  key_type     = var.key_type
  key_size     = var.key_size

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
  tags = merge(
    var.tags,
    { terraform = "true" }
  )
}