variable "ovh_api_region" {
  type        = string
  description = "OVH API endpoint region — påkrævet af delt providers.tf"
  default     = "ovh-eu"
}

variable "cloud_settings" {
  type = object({
    region = string
    ovh    = optional(object({ project_id = string }), null)
    azure = optional(object({
      subscription_id = string
      resource_group  = string
    }), null)
  })
  description = "Azure region og resource group"
  default = {
    region = "denmarkeast"
    azure = {
      subscription_id = "9cbb71c9-7f62-4277-a708-f89d1f020134"
      resource_group  = "rg-tbr-test"
    }
  }
}

variable "network_config" {
  type = object({
    name          = optional(string, "vnet-test_azure")
    address_space = list(string)
    subnets       = map(object({ cidr = string }))
  })
  description = "Azure VNet konfiguration"
  default = {
    name          = "vnet-test_azure"
    address_space = ["10.0.14.0/22"]
    subnets = {
      default = { cidr = "10.0.15.0/24" }
      aks     = { cidr = "10.0.14.0/24" }
    }
  }
}
