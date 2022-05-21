variable "security_contact" {
  type = map(string)

  default = {
    "email" = "kevin.brooke@virtualclarity.com"
    "phone" = "07706584425"
  }
}

variable "security_pricing" {
  default = "Standard"
}
