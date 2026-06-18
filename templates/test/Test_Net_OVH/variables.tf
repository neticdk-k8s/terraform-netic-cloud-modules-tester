variable "ovh_api_region" {
  type        = string
  description = "OVH API endpoint region (e.g. 'ovh-eu', 'ovh-ca')"
  default     = "ovh-eu"
}

variable "cloud_settings" {
  type = object({
    region = string
    ovh = optional(object({
      project_id = string
    }), null)
  })
  description = "OVH project and region"
  default = {
    region = "GRA9"
    ovh = {
      project_id = "bb219a2fd02c487798bbb0b349f622a5"
    }
  }
}

variable "network_config" {
  type = object({
    name    = optional(string, "vnet_test_ovh")
    vlan_id = number
    regions = list(object({
      region              = string
      subnet              = string
      dhcp                = optional(bool, true)
      no_gateway          = optional(bool, false)
      ip_allocation_start = optional(number, 10)
      ip_allocation_stop  = optional(number, 200)
    }))
  })
  description = "OVH private network (vRack) configuration"
  default = {
    name    = "vnet_test_ovh"
    vlan_id = 320
    regions = [
      {
        region              = "GRA9"
        subnet              = "10.0.14.0/24"
        dhcp                = true
        no_gateway          = false
        ip_allocation_start = 10
        ip_allocation_stop  = 200
      }
    ]
  }
}
