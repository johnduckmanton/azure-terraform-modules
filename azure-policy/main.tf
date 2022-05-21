resource "azurerm_policy_definition" "p_definition" {
  for_each            = var.policies
  name                = each.key
  display_name        = each.key
  description         = each.value["description"]
  management_group_id = each.value["management_group_id"]
  policy_rule         = file("${path.root}/../../resources/policies/rules/${each.key}.json")
  parameters          = file("${path.root}/../../resources/policies/parameters/${each.value["parameters_definition"]}")
  policy_type         = "Custom"
  mode                = "All"
}

resource "azurerm_policy_assignment" "p_assignment" {
  for_each             = var.policies
  name                 = substr(each.key, 0, 23)
  display_name         = each.key
  description          = each.value["description"]
  scope                = var.scope_id
  policy_definition_id = azurerm_policy_definition.p_definition[each.key].id
  parameters           = each.value["parameters_assignment"]
}
