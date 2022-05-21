variable "resource_group_name" {
  description = "Default resource group name that the database will be created in."
  type        = string
}

variable "location" {
  description = "Specifies the supported Azure location where the resource exists."
  type        = string
}

variable "server_version" {
  description = "The version for the new server. Valid values are: 2.0 (for v11 server) and 12.0 (for v12 server)."
  type        = string
  default     = "12.0"
}

variable "server_name" {
  description = "The name of the server and resources to be created."
  type        = string
}

variable "administrator_login" {
  description = "The administrator username of MySQL Server, leave empty to generate."
  type        = string
  default     = ""
}

variable "administrator_login_password" {
  description = "The administrator password of the MySQL Server, leave empty to generate."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Resource Tags."
  type        = map(string)
  default     = {}
}

variable "extended_auditing_enabled" {
  description = "Whether or not to enable extended auditing to a dedicated storage account"
  type        = bool
  default     = true
}

variable "storage_allowed_cidrs" {
  description = "CIDRs to allow access to the extended logging storage account"
  type        = list(string)
  default     = []
}

variable "connection_policy" {
  description = "The connection policy the server will use. Possible values are Default, Proxy, and Redirect"
  type        = string
  default     = "Default"
}

variable "public_network_access_enabled" {
  description = "Whether or not public network access is allowed for this server"
  type        = bool
  default     = false
}

variable "server_identity_enabled" {
  description = "Whether or not to create a MSI for the server"
  type        = bool
  default     = false
}

variable "azuread_administrator_enabled" {
  description = "Whether or not to set an Azure AD administrator"
  type        = bool
  default     = false
}

variable "threat_detection_policy_enabled" {
  description = "Whether or not to set an Azure AD administrator"
  type        = bool
  default     = true
}

variable "notification_email_addresses" {
  description = "List of email addresses to notify on events"
  type        = list(string)
  default     = []
}

variable "aad_login_username" {
  description = "Azure AD login username for the server"
  type        = string
  default     = ""
}

variable "aad_object_id" {
  description = "Azure AD object ID for the server administrator"
  type        = string
  default     = ""
}

// Example map: dbs = { db1 = { charset = "utf8", collation = "utf8_unicode_ci"} }
variable "dbs" {
  description = "Map of databases to create. Key is db name, values are: charset, collation"
  default     = {}
}

variable "retention_in_days" {
  description = "Number of days to keep extended logs"
  type        = number
  default     = 91
}

variable "foreach_config" {
  description = "Used as a count for a dynamic resource"
  type        = map(string)
  default     = { foo = "bar" }
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

variable "alert_dataread" {
  description = "Percent of physical data read usage to trigger an alert"
  type        = string
  default     = "95"
}

variable "alert_storage" {
  description = "Percent of storage usage to trigger an alert"
  type        = string
  default     = "80"
}

variable "alert_sessions" {
  description = "Percent of sessions to trigger an alert"
  type        = string
  default     = "90"
}

variable "alert_core_cpu" {
  description = "Percent of CPU usage to trigger an alert per database"
  type        = string
  default     = "95"
}

variable "alert_core_memory" {
  description = "Percent of memory usage to trigger an alert per database"
  type        = string
  default     = "95"
}

variable "alert_failed_connections" {
  description = "Number of failed connections in 5 minutes to trigger an alert"
  type        = string
  default     = "10"
}

variable "alert_tempdblog" {
  description = "Percent of tempdb log usage to trigger an alert"
  type        = string
  default     = "80"
}
