locals {
  name                    = "ccoe-security-export"
  short_name              = "ccoesecurityexport"
  resource_group_name     = "security-center-config-rg"
  resource_group_location = "northeurope"
}

data "azurerm_eventhub_namespace" "hub" {
  name                = var.auth_namespace_name
  resource_group_name = var.auth_resource_group_name
}

data "azurerm_resource_group" "hub" {
  name = var.auth_resource_group_name
}

resource "azurerm_policy_definition" "policy" {
  name                  = local.short_name
  display_name          = local.name
  description           = "Apply security center export configuration to the splunk event hub"
  policy_type           = "Custom"
  mode                  = "All"
  management_group_name = var.management_group_name
  policy_rule           = file("${path.root}/../../resources/policies/rules/ccoe-security-export.json")
  parameters            = file("${path.root}/../../resources/policies/parameters/ccoe-security-export.json")
}

resource "azurerm_policy_assignment" "policy" {
  name                 = local.short_name
  display_name         = local.name
  scope                = var.scope
  policy_definition_id = azurerm_policy_definition.policy.id
  description          = "Apply security center export configuration to the splunk event hub"
  location             = var.location
  identity { type = "SystemAssigned" }
  parameters = <<PARAMETERS
        {
            "resourceGroupName": {
                "value" : "${local.resource_group_name}"
            },
            "resourceGroupLocation": {
                "value" : "${local.resource_group_location}"
            },
            "eventHubName": {
                "value" : "${var.event_hub_name}"
            },
            "eventHubNamespaceResourceId": {
                "value" : "${data.azurerm_eventhub_namespace.hub.id}"
            },
            "eventHubSendPolicyName": {
                "value" : "${var.auth_name}"
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
  role_definition_name = "Contributor"
}
