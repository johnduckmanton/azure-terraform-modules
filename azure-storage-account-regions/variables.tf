variable "allowed_cidrs" {
  type    = list(string)
  default = []
}

variable "vnet_subnet_ids" {
  type    = list(string)
  default = []
}

variable "tags" {
  type = map(string)
}

variable "resource_group_name" {}
variable "storage_account_name_prefix" {}
variable "locations" {}

variable "account_replication_type" {
  default = "LRS"
}

variable "account_tier" {
  default = "Standard"
}

variable "account_kind" {
  default = "StorageV2"
}

variable "enable_https_traffic_only" {
  default = "true"
}

variable "default_action" {
  default = "Deny"
}

# Reducing the length to a maximum of 4 characters (3 with no number)
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