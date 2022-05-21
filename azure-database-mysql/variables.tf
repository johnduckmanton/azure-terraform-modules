variable "resource_group_name" {
  description = "Default resource group name that the database will be created in."
  type        = string
}

variable "location" {
  description = "Specifies the supported Azure location where the resource exists."
  type        = string
}

variable "name" {
  description = "The name of the server and resources to be created."
  type        = string
}

variable "admin_username" {
  description = "The administrator username of MySQL Server, leave empty to generate."
  type        = string
  default     = ""
}

variable "password" {
  description = "The administrator password of the MySQL Server, leave empty to generate."
  type        = string
  default     = ""
}

variable "db_version" {
  description = "Specifies the version of MySQL to use."
  type        = string
  default     = "5.7"
}

variable "ssl_enforcement_enabled" {
  description = "Specifies if SSL should be enforced on connections. Possible values are true and false."
  type        = bool
  default     = true
}

variable "ssl_minimal_tls_version_enforced" {
  description = "Specifies the minimal TLS version that must be used."
  type        = string
  default     = "TLS1_2"
}

variable "sku_name" {
  description = "Specifies the SKU Name for this MySQL Server. The name of the SKU, follows the tier + family + cores pattern (e.g. B_Gen4_1, GP_Gen5_8)."
  type        = string
  default     = "GP_Gen5_2"
}

variable "storage_mb" {
  description = "Max storage allowed for a server. Possible values are between 5120 MB(5GB) and 1048576 MB(1TB) for the Basic SKU and between 5120 MB(5GB) and 4194304 MB(4TB) for General Purpose/Memory Optimized SKUs."
  type        = number
  default     = 102400
}

variable "backup_retention_days" {
  description = "Backup retention days for the server, supported values are between 7 and 35 days."
  type        = number
  default     = 7
}

variable "geo_redundant_backup_enabled" {
  description = "Enable Geo-redundant or not for server backup. Valid values for this property are true or false, not supported for the basic tier."
  type        = bool
  default     = false
}

variable "infrastructure_encryption_enabled" {
  description = "Add a second layer of encryption for your data using new encryption algorithm which gives additional data protection."
  type        = bool
  default     = false # Disabled due to Azure API limitation.
}

variable "public_network_access_enabled" {
  description = "Whether or not public network access is allowed for this server."
  type        = bool
  default     = false
}

variable "auto_grow_enabled" {
  description = "(Optional) Defines whether autogrow is enabled or disabled for the storage. Valid values are true or false."
  type        = bool
  default     = true
}

variable "create_mode" {
  description = "The creation mode. Can be used to restore or replicate existing servers. Valid values are Default, Replica, GeoRestore, and PointInTimeRestore."
  type        = string
  default     = "Default"
}

variable "creation_source_server_id" {
  description = "For creation modes other than Default, the source server ID to use."
  type        = string
  default     = null
}

variable "restore_point_in_time" {
  description = "When create_mode is PointInTimeRestore, specifies the point in time to restore from creation_source_server_id."
  type        = string
  default     = null
}

variable "charset" {
  description = "Specifies the Charset for the MySQL Database, which needs to be a valid MySQL Charset."
  type        = string
  default     = "utf8"
}

variable "collation" {
  description = "Specifies the Collation for the MySQL Database, which needs to be a valid MySQL Collation."
  type        = string
  default     = "utf8_unicode_ci"
}

// Example map: dbs = { db1 = { charset = "utf8", collation = "utf8_unicode_ci"} }
variable "dbs" {
  description = "Map of databases to create. Key is db name, values are: charset, collation"
  default     = {}
}

variable "firewall_rules" {
  description = "Map of firewall rules to create. Key is rule name, values are start_ip, end_ip"
  type        = map(map(string))
  default     = { azure-services-fwr = { start_ip = "0.0.0.0", end_ip = "0.0.0.0" } }
}

variable "vnet_rules" {
  description = "Map of vnet rules to create. Key is name, value is vnet id"
  type        = map(map(string))
  default     = {}
}

variable "mysql_configurations" {
  description = "Map of MySQL configuration settings to create. Key is name, value is vnet id"
  type        = map(map(string))
  default     = {}
}

variable "tags" {
  description = "Resource Tags."
  type        = map(string)
  default     = {}
}

variable "action_group_id" {
  description = "Action group to send monitoring alerts to"
  type        = string
  default     = ""
}

variable "alerts_enabled" {
  description = "Enables alerts to an action group"
  type        = bool
  default     = true
}

variable "alert_cpu" {
  description = "Percent of CPU usage to trigger an alert"
  type        = string
  default     = "95"
}

variable "alert_memory" {
  description = "Percent of memory usage to trigger an alert"
  type        = string
  default     = "90"
}

variable "alert_storage" {
  description = "Percent of storage usage to trigger an alert"
  type        = string
  default     = "80"
}

variable "alert_log_storage" {
  description = "Percent of log storage usage to trigger an alert"
  type        = string
  default     = "80"
}

variable "alert_failed_connections" {
  description = "Number of failed connections in 5 minutes to trigger an alert"
  type        = string
  default     = "10"
}