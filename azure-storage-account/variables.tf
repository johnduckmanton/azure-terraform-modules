variable "allowed_cidrs" {
  type        = list(string)
  default     = []
  description = "CIDRs to allow access to the storage account"
}

variable "vnet_subnet_ids" {
  type        = list(string)
  default     = []
  description = "VNet subnet IDs to allow access to the storage account"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to resources in the module"
}

variable "location" {
  description = "The location for the deployment"
}

variable "storage_account_name" {
  description = "Specifies the name of the storage account."
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the storage account."
}

variable "account_replication_type" {
  default     = "LRS"
  description = "Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS."
}

variable "account_tier" {
  default     = "Standard"
  description = "Defines the Tier to use for this storage account. Valid options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid."
}

variable "account_kind" {
  default     = "StorageV2"
  description = "Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2."
}

variable "access_tier" {
  default     = "Hot"
  description = "Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are Hot and Cool, defaults to Hot."
}

variable "enable_https_traffic_only" {
  default     = true
  description = "Boolean flag which forces HTTPS if enabled"
}

variable "is_hns_enabled" {
  default     = false
  description = "Is Hierarchical Namespace enabled? This can be used with Azure Data Lake Storage Gen 2"
}

variable "container_names" {
  type        = list(string)
  default     = []
  description = "A list of container names to create in the storage account"
}

variable "table_names" {
  type        = list(string)
  default     = []
  description = "A list of table names to create in the storage account"
}

variable "share_names" {
  type        = list(string)
  default     = []
  description = "A list of file share names to create in the storage account"
}

variable "quota" {
  default     = "1200"
  description = "The maximum size of the share, in gigabytes."
}

variable "default_action" {
  default     = "Deny"
  description = "Specifies the default action of allow or deny when no other rules match."
}

variable "network_bypass" {
  default     = ["AzureServices", "Logging", "Metrics"]
  description = "Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Valid options are any combination of Logging, Metrics, AzureServices, or None."
}

variable "container_access_type" {
  default     = "private"
  description = "The Access Level configured for this Container. Possible values are blob, container or private."
}

variable "enable_queue_logging" {
  default     = true
  description = "Indicates whether all requests should be logged."
}

variable "queue_hour_metric_retention" {
  default     = 7
  description = "Specifies the number of days that logs will be retained."
}

variable "queue_metric_version" {
  default     = "1.0"
  description = " The version of storage analytics to configure."
}

variable "queue_logging_retention" {
  default     = 90
  description = "Specifies the number of days that logs will be retained."
}

variable "queue_minute_metric_retention" {
  default     = 7
  description = "Specifies the number of days that logs will be retained."
}