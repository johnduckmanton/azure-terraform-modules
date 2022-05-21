variable "tags" {
  type = map(string)
}

variable "location" {}

variable "environment" {}

variable "resource_group_name" {}

variable "nsg_id" {}

variable "subnet_id" {}

variable "vm_size" {
  default = "Standard_B4ms"
}

variable "vm_disk_size" {
  default = "50"
}

variable "vm_8_custom" {}

variable "publisher" {
  default = "RedHat"
}

variable "offer" {
  default = "RHEL"
}

variable "sku" {
  default = "7.4"
}

variable "img_version" {
  default = "latest"
}

variable "admin_username" {
  default = "pretend_admin"
}

variable "admin_password" {
  default = ".Please_Don't_Use_th1s_P@ssw0rd!!!"
}

variable "vm_location_prefix_map" {
  type = map(string)

  default = {
    westus      = "us"
    eastus      = "us"
    centralus   = "us"
    eastus2     = "us"
    northeurope = "eu"
    westeurope  = "eu"
    ukwest      = "gb"
    uksouth     = "gb"
  }
}

variable "vm_env_prefix_name" {
  type = map(string)

  default = {
    prod = "p"
    uat  = "u"
    test = "t"
    qa   = "t"
    dev  = "d"
    demo = "d"
  }
}

variable "image_id" {
  default = ""
}

variable "sa_uri" {
  default = ""
}

variable "public" {
  default = false
}

variable "create_msi" {
  default = false
}
