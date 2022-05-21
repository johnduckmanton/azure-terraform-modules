variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created"
  type        = string
}

variable "global_region_lookup" {
  description = "A lookup used to convert the Azure region to a single character global region"
  type        = map(string)
  default = {
    northeurope = "E"
    westeurope  = "E"
  }
}

variable "cloud_region_lookup" {
  description = "A lookup used to convert the Azure region to a single character cloud region"
  type        = map(string)
  default = {
    northeurope = "I"
    westeurope  = "A"
  }
}
variable "environment_lookup" {
  description = "A lookup used to convert the environment to a single character"
  type        = map(string)
  default = {
    dev  = "D"
    sbx  = "X"
    uat  = "U"
    prod = "P"
    sit  = "S"
  }
}
variable "purpose_lookup" {
  description = "A lookup used to convert the purpose to a single character"
  type        = map(string)
  default = {
    application      = "AP"
    database         = "DB"
    webserver        = "WW"
    terminalservices = "TS"
  }
}

variable "vm_purpose" {
  description = "The purpose of the VM"
  type        = string
  default     = "application"
}

variable "is_windows" {
  description = "Boolean flag to notify when the VM is Windows."
  type        = bool
  default     = false
}

variable "vm_init_number" {
  description = "The number to start for the VM naming (count is added to this number)"
  type        = number
  default     = 0
}

variable "boot_diagnostics" {
  description = "(Optional) Enable or Disable boot diagnostics"
  type        = bool
  default     = false
}

variable "storage_allowed_cidrs" {
  description = "CIDRs to allow access to the extended logging storage account"
  type        = list(string)
  default     = []
}

variable "environment" {
  description = "Development environment for resource; prod, uat, sit, dev, sbx"
  type        = string
}

variable "location" {
  description = "Azure location the resource will be deployed into"
  type        = string
}

variable "additional_capabilities" {
  description = "A additional_capabilities block as defined below."
  type        = list
  default     = []
}

variable "additional_unattend_content" {
  description = "One or more additional_unattend_content blocks as defined below."
  type        = list
  default     = []
}

variable "admin_password" {
  description = "The Password which should be used for the local-administrator on this Virtual Machine."
  type        = string
  default     = ""
}

variable "enable_ssh_key" {
  type        = bool
  description = "Enable ssh key authentication in Linux virtual Machine"
  default     = false
}

variable "admin_ssh_key_public_key" {
  description = "The Public Key which should be used for authentication, which needs to be at least 2048-bit and in ssh-rsa format."
  type        = string
  default     = ""
}

variable "admin_username" {
  description = "The username of the local administrator used for the Virtual Machine."
  type        = string
  default     = ""
}

variable "allow_extension_operations" {
  description = "Should Extension Operations be allowed on this Virtual Machine?"
  type        = bool
  default     = null
}

variable "custom_data" {
  description = "The Base64-Encoded Custom Data which should be used for this Virtual Machine."
  type        = string
  default     = null
}

variable "dedicated_host_id" {
  description = "The ID of a Dedicated Host where this machine should be run on."
  type        = string
  default     = null
}

variable "disable_password_authentication" {
  description = "Should Password Authentication be disabled on this Virtual Machine?"
  type        = bool
  default     = false
}

variable "enable_automatic_updates" {
  description = "Specifies if Automatic Updates are Enabled for the Windows Virtual Machine."
  type        = bool
  default     = true
}

variable "eviction_policy" {
  description = "Specifies what should happen when the Virtual Machine is evicted for price reasons when using a Spot instance. At this time the only supported value is Deallocate."
  type        = string
  default     = null
}

variable "identity" {
  description = "An identity block supports the following: type - The type of Identity SystemAssigned or UserAssigned. identity_ids - A list of User Managed Identity ID's"
  type        = list
  default = [
    {
      type         = "SystemAssigned"
      identity_ids = []
    }
  ]
}

variable "license_type" {
  description = "Specifies the type of on-premise license. Either None, Windows_Client and Windows_Server."
  type        = string
  default     = "Windows_Server"
}

variable "max_bid_price" {
  description = "The maximum price you're willing to pay for this Virtual Machine, in US Dollars; which must be greater than the current spot price."
  type        = number
  default     = null
}

variable "os_disk_caching" {
  description = "The Type of Caching which should be used for the Internal OS Disk. Possible values are None, ReadOnly and ReadWrite."
  type        = string
  default     = "ReadWrite"
}

variable "os_disk_encryption_set_id" {
  description = "The ID of the Disk Encryption Set which should be used to Encrypt this OS Disk."
  type        = string
  default     = null
}

variable "os_disk_size_gb" {
  description = "The Size of the Internal OS Disk in GB, if you wish to vary from the size used in the image this Virtual Machine is sourced from."
  type        = number
  default     = null
}

variable "os_disk_storage_account_type" {
  description = "The Type of Storage Account which should back this the Internal OS Disk. Possible values are Standard_LRS, StandardSSD_LRS and Premium_LRS."
  type        = string
  default     = "Standard_LRS"
}

variable "os_disk_write_accelerator_enabled" {
  description = "Should Write Accelerator be Enabled for this OS Disk?"
  type        = bool
  default     = false
}

variable "plan" {
  description = "A plan block if using Marketplace images: name, product, publisher"
  type        = list
  default     = []
}

variable "priority" {
  description = "Specifies the priority of this Virtual Machine. Possible values are Regular and Spot"
  type        = string
  default     = "Regular"
}

variable "provision_vm_agent" {
  description = "Should the Azure VM Agent be provisioned on this Virtual Machine?"
  type        = bool
  default     = true
}

variable "proximity_placement_group_id" {
  description = "The ID of the Proximity Placement Group which the Virtual Machine should be assigned to."
  type        = string
  default     = null
}

variable "secret" {
  description = "One or more secret blocks: certificate/url - URL of the certificate, key_vault_id - The ID of the Key Vault from which all Secrets should be sourced."
  type        = list
  default     = []
}

variable "size" {
  description = "The SKU which should be used for this Virtual Machine, such as Standard_F2."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "source_image_id" {
  description = "The ID of the Image which this Virtual Machine should be created from."
  type        = string
  default     = null
}

variable "source_image_reference_offer" {
  description = "offer type, ex. WindowsServer, UbuntuServer"
  type        = string
  default     = ""
}

variable "source_image_reference_publisher" {
  description = "publisher type, ex. MicrosoftWindowsServer, Canonical"
  type        = string
  default     = ""
}

variable "source_image_reference_sku" {
  description = "sku type, ex. 2016-Datacenter, 16.04-LTS"
  type        = string
  default     = ""
}

variable "source_image_reference_version" {
  description = "version type, ex. latest"
  type        = string
  default     = "latest"
}

variable "timezone" {
  description = "Specifies the Time Zone which should be used by the Virtual Machine, the possible values are defined here."
  type        = string
  default     = null
}

variable "vm_count" {
  description = "number of VMs to create"
  type        = number
  default     = 1
}

variable "winrm_listener" {
  description = "One or more winrm_listener block: Protocol - Http or Https, certificate_url - URL of a Key Vault Certificate, if using Https."
  type        = list
  default     = []
}

variable "enable_accelerated_networking" {
  description = "(Optional) Enable accelerated networking on Network interface"
  type        = bool
  default     = false
}

variable "vnet_subnet_id" {
  description = "The subnet id of the virtual network where the virtual machines will reside."
  type        = string
}

variable "count_public_ip" {
  description = "Number of public IPs to assign corresponding to one IP per vm. Set to 0 to not assign any public IP addresses."
  type        = string
  default     = "0"
}

variable "allocation_method" {
  description = "Defines how an IP address is assigned. Options are Static or Dynamic."
  type        = string
  default     = "Dynamic"
}

variable "public_ip_dns" {
  description = "Optional globally unique per datacenter region domain name label to apply to each public ip address. e.g. thisvar.varlocation.cloudapp.azure.com where you specify only thisvar here. This is an array of names which will pair up sequentially to the number of public ips defined in var.count_public_ip. One name or empty string is required for every public ip. If no public ip is desired, then set this to an array with a single empty string."
  default     = [null]
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map
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
  default     = "15"
}

variable "join_domain" {
  description = "Wether to join the domain or not"
  type        = bool
  default     = false
}

variable "domain_join_user" {
  description = "The accounts username to join the domain with (username only)"
  type        = string
  default     = ""
}

variable "domain_join_password" {
  description = "The accounts password to join the domain with"
  type        = string
  default     = ""
}