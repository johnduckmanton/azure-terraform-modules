variable "scope" {}
variable "location" {}
variable "management_group_name" {}

variable "auth_name" {
  default = "RootManageSharedAccessKey"
}

variable "auth_namespace_name" {
  default = "group-foundserv-prod-rg-eventhub-securitylogging"
}

variable "auth_resource_group_name" {
  default = "group-foundserv-prod-rg-eventhub"
}

variable "resource_type" {
  default = "nsg"
}

variable "description" {
  default = "Applies diagnostic settings to send to Event hub"
}

variable "policy_effect" {
  description = "Enable or disable the execution of the policy (DeployIfNotExists or Disabled)"
  default     = "DeployIfNotExists"
}

variable "metrics_enabled" {
  default = "True"
}

variable "logs_enabled" {
  default = "True"
}

variable "location_lookup" {
  default = {
    eastasia           = "eas"
    southeastasia      = "sea"
    centralus          = "cus"
    eastus             = "eus"
    eastus2            = "eus2"
    westus             = "wus"
    northcentralus     = "ncu"
    southcentralus     = "scu"
    northeurope        = "neu"
    westeurope         = "weu"
    japanwest          = "jpw"
    japaneast          = "jpe"
    brazilsouth        = "brs"
    australiaeast      = "aue"
    australiasoutheast = "aus"
    southindia         = "sin"
    centralindia       = "cin"
    westindia          = "win"
    canadacentral      = "cac"
    canadaeast         = "cae"
    uksouth            = "gbs"
    ukwest             = "gbw"
    westcentralus      = "wcu"
    westus2            = "wus2"
    koreacentral       = "krc"
    koreasouth         = "krs"
    francecentral      = "frc"
    francesouth        = "frs"
    australiacentral   = "auc"
    australiacentral2  = "auc2"
    uaecentral         = "aec"
    uaenorth           = "aen"
    southafricanorth   = "zan"
    southafricawest    = "zaw"
    switzerlandnorth   = "chn"
    switzerlandwest    = "chw"
    germanynorth       = "den"
    germanywestcentral = "dec"
    norwaywest         = "now"
    norwayeast         = "noe"
  }
}