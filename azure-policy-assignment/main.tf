# TF BUG: https://github.com/terraform-providers/terraform-provider-azurerm/issues/3597
# We plan to lookup each ID on its display name in this module but cannot at the moment due to the above bug.
//data "azurerm_policy_definition" "p_definition" {
//  for_each             = var.policies
//  display_name = "[Preview]: Audit CIS Microsoft Azure Foundations Benchmark 1.1.0 recommendations and deploy specific supporting VM Extensions"
//}

resource "azurerm_policy_assignment" "p_assignment" {
  for_each             = var.policies
  scope                = var.scope_id
  name                 = substr(each.key, 0, 23)
  display_name         = each.key
  description          = each.value["description"]
  policy_definition_id = each.value["policy_definition_id"]
  parameters           = each.value["parameters"]
}
