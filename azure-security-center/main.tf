resource "azurerm_security_center_contact" "scc" {
  alert_notifications = true
  alerts_to_admins    = true
  email               = var.security_contact["email"]
  phone               = var.security_contact["phone"]
}

resource "azurerm_security_center_subscription_pricing" "scp" {
  tier = var.security_pricing
}
