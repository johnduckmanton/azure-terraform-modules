# azure-modules

Terraform modules for Azure resources.

Designed to be approved, re-usable resource deployments.
 
## How to use a module
```
module "nsg" {
  source = "../../../../azure-modules/azure-nsg"

  rg_name  = var.rg_name
  location = var.region
  nsg_name = var.nsg_name
  rules    = var.rules
  tags = merge(
    var.tags,
    { customer = local.customer },
    { project = local.project },
    { environment = local.environment }
  )
}
```
## Requirements
 - Terraform v0.12.20
 - Azure CLI
 - A local SSH key to access to the source (Bitbucket)
