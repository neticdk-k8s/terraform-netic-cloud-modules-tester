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
    region = "UK1"
    ovh = {
      project_id = "bb219a2fd02c487798bbb0b349f622a5"
    }
  }
}

variable "networks" {
  type = list(object({
    name    = string
    vlan_id = number
    regions = list(object({
      region              = string
      subnet              = string
      dhcp                = optional(bool, true)
      no_gateway          = optional(bool, false)
      ip_allocation_start = optional(number, 10)
      ip_allocation_stop  = optional(number, 200)
    }))
  }))
  description = "OVH private (vRack) networks. Hvert element bliver til et privat netværk + subnet, og VM'en får et NIC på hvert."

  validation {
    condition     = length(var.networks) == length(distinct([for n in var.networks : n.name]))
    error_message = "Netværksnavne skal være unikke."
  }

  default = [
    {
      name    = "vnet_test_opnsense_ovh_tbr"
      vlan_id = 321
      regions = [
        {
          region     = "UK1"
          subnet     = "10.0.25.0/24"
          dhcp       = true
          no_gateway = true # OPNsense skal selv være gateway på det private net
        }
      ]
    },
    {
      name    = "vnet_test2_opnsense_ovh"
      vlan_id = 324
      regions = [
        {
          region     = "UK1"
          subnet     = "10.0.25.0/24"
          dhcp       = true
          no_gateway = true
        }
      ]
    },
    {
      name    = "vnet_test3_opnsense_ovh"
      vlan_id = 326
      regions = [
        {
          region     = "UK1"
          subnet     = "10.0.27.0/24"
          dhcp       = true
          no_gateway = true
        }
      ]
    },
  ]
}

variable "vm_config" {
  type = object({
    name             = optional(string, "opnsense-fw-test_tbr")
    size             = optional(string, "b2-7")
    resource_group   = optional(string, "rg-test-opnsense")
    image_name       = optional(string, "OPNsense26_1") #"opnsense-custom-26-10"
    ssh_public_key   = optional(string, null)
    create_public_ip = optional(bool, true)
    security_groups  = optional(list(string), ["default"])
  })
  description = "OPNsense VM configuration. image_name skal matche et OPNsense-image uploadet til OVH-projektet (Glance)."
  default     = {}
}


variable "test_vm_images" {
  type        = list(string)
  description = "Test-images til de tre VM-instanser (index 0, 1, 2 svarer til vm[1], vm[2], vm[3])"
  default     = ["vpn3_github", "vpn2_custom", "OPNsense26_1"]
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the VM"
  default = {
    environment = "test"
    purpose     = "opnsense-firewall"
  }
}
