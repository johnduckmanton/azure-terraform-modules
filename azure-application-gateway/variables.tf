variable "name_prefix" {
  description = "Name of the spoke virtual network."
}

variable "resource_group_name" {
  description = "Name of resource group to deploy resources in."
}

variable "location" {
  description = "The Azure Region in which to create resource."
}

variable "subnet_id" {
  description = "Id of the subnet to deploy Application Gateway."
}

variable "listener_protocol" {
  description = "The listener protocol"
  default     = "Https"
}

variable "diagnostics" {
  description = "Diagnostic settings for those resources that support it. See README.md for details on configuration."
  type        = bool
  default     = true
}

variable "zones" {
  description = "A collection of availability zones to spread the Application Gateway over."
  type        = list(string)
  default     = null
}

variable "waf_enabled" {
  description = "Set to true to enable WAF on Application Gateway."
  type        = bool
  default     = false
}

variable "waf_configuration" {
  description = "Configuration block for WAF."
  type        = object({ enabled = bool, firewall_mode = string, rule_set_type = string, rule_set_version = string, file_upload_limit_mb = number, max_request_body_size_kb = number })
  default     = null
}

variable "custom_policies" {
  description = "List of custom firewall policies. See https://docs.microsoft.com/en-us/azure/application-gateway/custom-waf-rules-overview."
  type        = list(object({ name = string, rule_type = string, action = string, match_conditions = list(object({ match_variables = list(object({ match_variable = string, selector = string })), operator = string, negation_condition = bool, match_values = list(string) })) }))
  default     = []
}

variable "ssl_policy_name" {
  description = "SSL Policy name"
  default     = "AppGwSslPolicy20170401"
}

variable "custom_error" {
  description = "List of custom error configurations, only support status code `HttpStatus403` and `HttpStatus502`."
  type        = list(object({ status_code = string, error_page_url = string }))
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources created."
  type        = map(string)
}

variable "retention_days" {
  description = "Number of days to keep diagnostic logs"
  type        = number
  default     = 90
}

variable "is_public" {
  description = "Creates a public IP for the APPGW"
  type        = bool
  default     = false
}

variable "cert_data" {
  description = "The file resource for the HTTPS PFX cert"
  type        = string
  default     = ""
}

variable "cert_password" {
  description = "The PFX certificate password"
  type        = string
  default     = ""
}

variable "alerts_enabled" {
  description = "Enables alerts to an action group"
  type        = bool
  default     = true
}

variable "action_group_id" {
  description = "Action group to send monitoring alerts to"
  type        = string
  default     = ""
}

variable "alert_cpu" {
  description = "Percent of CPU usage to trigger an alert"
  type        = string
  default     = "95"
}

variable "alert_failed_requests" {
  description = "Number of failed requests in 5 minutes to trigger an alert"
  type        = string
  default     = "10"
}

variable "alert_unhealthy_hosts" {
  description = "Number of unhealthy hosts in 5 minutes to trigger an alert"
  type        = string
  default     = "1"
}

variable "min_protocol_version" {
  description = "The minimum required protocol version"
  type        = string
  default     = "TLSv1_2"
}