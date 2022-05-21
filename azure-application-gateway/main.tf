locals {
  sku_name = var.waf_enabled ? "WAF_v2" : "Standard_v2"
  sku_tier = var.waf_enabled ? "WAF_v2" : "Standard_v2"

  backend_address_pool_name      = "${var.name_prefix}-beap"
  frontend_port_name             = "${var.name_prefix}-feport"
  frontend_ip_configuration_name = "${var.name_prefix}-feip"
  gateway_ip_configuration_name  = "${var.name_prefix}-gwip"
  http_setting_name              = "${var.name_prefix}-be-htst"
  listener_name                  = "${var.name_prefix}-httplstn"
  request_routing_rule_name      = "${var.name_prefix}-rqrt"
  public_ip_name                 = "${var.name_prefix}-pip"
  app_gw_name                    = "${var.name_prefix}-agw"
  app_gw_cert                    = "${var.name_prefix}-cert"
}

resource "azurerm_public_ip" "main" {
  count               = var.is_public ? 1 : 0
  name                = local.public_ip_name
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Dynamic"
  sku                 = "Standard"

  tags = merge(
    var.tags,
    { terraform = "true" }
  )
}

resource "azurerm_application_gateway" "main" {
  name                = local.app_gw_name
  resource_group_name = var.resource_group_name
  location            = var.location
  enable_http2        = true
  zones               = var.zones

  dynamic "autoscale_configuration" {
    for_each = var.is_public ? [1] : []
    content {
      min_capacity = 1
      max_capacity = 125
    }
  }

  sku {
    name     = var.is_public ? local.sku_name : "Standard_Small"
    tier     = var.is_public ? local.sku_tier : "Standard"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = local.gateway_ip_configuration_name
    subnet_id = var.subnet_id
  }

  dynamic "frontend_ip_configuration" {
    for_each = var.is_public ? [1] : []
    content {
      name                 = "${local.frontend_ip_configuration_name}-public"
      public_ip_address_id = azurerm_public_ip.main.id
    }
  }

  frontend_ip_configuration {
    name                          = "${local.frontend_ip_configuration_name}-private"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.subnet_id
  }

  frontend_port {
    name = "${local.frontend_port_name}-80"
    port = 80
  }

  frontend_port {
    name = "${local.frontend_port_name}-443"
    port = 443
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/ping/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = "${local.frontend_ip_configuration_name}-private"
    frontend_port_name             = "${local.frontend_port_name}-443"
    protocol                       = var.listener_protocol
    ssl_certificate_name           = local.app_gw_cert
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

  ssl_policy {
    policy_type          = "Predefined"
    policy_name          = var.ssl_policy_name
    min_protocol_version = var.min_protocol_version
  }

  ssl_certificate {
    name     = local.app_gw_cert
    data     = var.cert_data
    password = var.cert_password
  }

  dynamic "waf_configuration" {
    for_each = var.waf_enabled == true ? var.waf_configuration : {}
    content {
      enabled                  = var.waf_enabled
      firewall_mode            = coalesce(var.waf_configuration.firewall_mode, "Prevention")
      rule_set_type            = coalesce(var.waf_configuration.rule_set_type, "OWASP")
      rule_set_version         = coalesce(var.waf_configuration.rule_set_version, "3.0")
      file_upload_limit_mb     = coalesce(var.waf_configuration.file_upload_limit_mb, 100)
      max_request_body_size_kb = coalesce(var.waf_configuration.max_request_body_size_kb, 128)
    }
  }

  dynamic "custom_error_configuration" {
    for_each = var.custom_error
    iterator = ce
    content {
      status_code           = ce.value.status_code
      custom_error_page_url = ce.value.error_page_url
    }
  }

  tags = merge(var.tags, { terraform = "true", managed-by-k8s-ingress = "F", last-updated-by-k8s-ingress = "F" })

  // Ignore most changes as they may be managed elsewhere
  lifecycle {
    ignore_changes = [
      backend_address_pool,
      backend_http_settings,
      frontend_port,
      http_listener,
      probe,
      request_routing_rule,
      url_path_map,
      ssl_certificate,
      redirect_configuration,
      autoscale_configuration,
      tags["managed-by-k8s-ingress"],
      tags["last-updated-by-k8s-ingress"],
    ]
  }
}

resource "random_id" "appgw-sa" {
  keepers = {
    appgw = azurerm_application_gateway.main.name
  }

  byte_length = 6
}

resource "azurerm_storage_account" "storage" {
  count                     = var.diagnostics ? 1 : 0
  name                      = "appgwdiag${lower(random_id.appgw-sa.hex)}"
  resource_group_name       = var.resource_group_name
  location                  = var.location
  account_replication_type  = "LRS"
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  access_tier               = "Hot"
  enable_https_traffic_only = true

  network_rules {
    bypass         = ["AzureServices", "Logging", "Metrics"]
    default_action = "Deny"
    ip_rules       = []
  }

  queue_properties {
    hour_metrics {
      enabled               = true
      version               = "1.0"
      include_apis          = true
      retention_policy_days = 7
    }
    logging {
      delete                = true
      read                  = true
      version               = "1.0"
      write                 = true
      retention_policy_days = 91
    }
    minute_metrics {
      enabled               = true
      version               = "1.0"
      include_apis          = true
      retention_policy_days = 7
    }
  }

  lifecycle {
    ignore_changes = [account_kind]
  }

  tags = merge(
    var.tags,
    { terraform = "true" }
  )
}

resource "azurerm_monitor_diagnostic_setting" "main" {
  count              = var.diagnostics ? 1 : 0
  name               = "${local.app_gw_name}-diag"
  target_resource_id = azurerm_application_gateway.main.id
  storage_account_id = azurerm_storage_account.storage[0].id

  log {
    category = "ApplicationGatewayAccessLog"
    enabled  = true
    retention_policy {
      enabled = true
      days    = var.retention_days
    }
  }

  log {
    category = "ApplicationGatewayPerformanceLog"
    enabled  = true
    retention_policy {
      enabled = true
      days    = var.retention_days
    }
  }

  log {
    category = "ApplicationGatewayFirewallLog"
    enabled  = true
    retention_policy {
      enabled = true
      days    = var.retention_days
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true
    retention_policy {
      enabled = true
      days    = var.retention_days
    }
  }
}
