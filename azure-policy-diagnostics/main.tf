locals {
  name       = format("ccoe-diagnostics-%s", lower(var.resource_type))
  short_name = format("ccoediag%s", substr(lower(var.resource_type), 0, 12)) # Limits name to 24 characters
}

data "azurerm_eventhub_namespace_authorization_rule" "hub" {
  name                = var.auth_name
  namespace_name      = var.auth_namespace_name
  resource_group_name = var.auth_resource_group_name
}

data "azurerm_resource_group" "hub" {
  name = var.auth_resource_group_name
}

resource "azurerm_policy_definition" "policy" {
  name                  = format("%s%s", local.short_name, lookup(var.location_lookup, var.location))
  display_name          = format("%s-%s", local.name, var.location)
  description           = "Apply diagnostic logs for ${var.resource_type} to the splunk event hub"
  policy_type           = "Custom"
  mode                  = "All"
  management_group_name = var.management_group_name
  policy_rule           = file("${path.root}/../../resources/policies/rules/ccoe-diagnostics-${var.resource_type}.json")
  parameters            = file("${path.root}/../../resources/policies/parameters/ccoe-diagnostics-${var.resource_type}.json")
}

resource "azurerm_policy_assignment" "policy" {
  name                 = format("%s%s", local.short_name, lookup(var.location_lookup, var.location))
  display_name         = format("%s-%s", local.name, var.location)
  scope                = var.scope
  policy_definition_id = azurerm_policy_definition.policy.id
  description          = "Apply diagnostic logs for ${var.resource_type} to the splunk event hub"
  location             = var.location
  identity { type = "SystemAssigned" }
  parameters = <<PARAMETERS
        {
            "effect": {
                "value" : "${var.policy_effect}"
            },
            "profileName": {
                "value" : "setbypolicy_${var.resource_type}_diags"
            },
            "eventHubRuleId": {
                "value" : "${data.azurerm_eventhub_namespace_authorization_rule.hub.id}"
            },
            "eventHubLocation": {
                "value" : "${var.location}"
            },
            "metricsEnabled": {
                "value" : "${var.metrics_enabled}"
            },
            "logsEnabled": {
                "value" : "${var.logs_enabled}"
            }
        }
        PARAMETERS
}

resource "azurerm_role_assignment" "mg-monitoring-contributor" {
  principal_id         = azurerm_policy_assignment.policy.identity[0].principal_id
  scope                = var.scope
  role_definition_name = "Contributor"
}

resource "azurerm_role_assignment" "rg-aehdo" {
  principal_id         = azurerm_policy_assignment.policy.identity[0].principal_id
  scope                = data.azurerm_resource_group.hub.id
  role_definition_name = "Azure Event Hubs Data Owner"
}
