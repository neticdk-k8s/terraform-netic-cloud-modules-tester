variable "ovh_api_region" {
  type        = string
  description = "OVH API endpoint region (e.g. 'ovh-eu', 'ovh-ca')"
  default     = "ovh-ca"
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
      project_id = "67241ca1d8b349ce9f6fefb72348bad2"
    }
  }
}

variable "network_config" {
  type = object({
    name    = optional(string, "vnet_test_opnsense_ovh")
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
    name    = "vnet_test_opnsense_ovh"
    vlan_id = 321
    regions = [
      {
        region              = "GRA9"
        subnet              = "10.0.15.0/24"
        dhcp                = true
        no_gateway          = true # OPNsense skal selv være gateway på det private net
        ip_allocation_start = 10
        ip_allocation_stop  = 200
      }
    ]
  }
}
variable "network2_config" {
  type = object({
    name    = optional(string, "vnet_test_opnsense_ovh")
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
    name    = "vnet2_test_opnsense_ovh"
    vlan_id = 322
    regions = [
      {
        region              = "GRA9"
        subnet              = "10.0.16.0/24"
        dhcp                = true
        no_gateway          = true # OPNsense skal selv være gateway på det private net
        ip_allocation_start = 10
        ip_allocation_stop  = 200
      }
    ]
  }
}

variable "vm_config" {
  type = object({
    name             = optional(string, "opnsense-fw-test")
    size             = optional(string, "b2-7")
    resource_group   = optional(string, "rg-test-opnsense")
    image_name       = optional(string, "OPNsense26_1")
    ssh_public_key   = optional(string, null)
    create_public_ip = optional(bool, true)
    security_groups  = optional(list(string), ["default"])
  })
  description = "OPNsense VM configuration. image_name skal matche et OPNsense-image uploadet til OVH-projektet (Glance)."
  default     = {}
}

variable "image_config" {
  type = object({
    upload           = optional(bool, true)
    name             = optional(string, "OPNsense")
    source_url       = optional(string, "https://mirror.dns-root.de/opnsense/releases/25.1/OPNsense-25.1-nano-amd64.img.bz2")
    local_file_path  = optional(string, null)
    disk_format      = optional(string, "raw")
    container_format = optional(string, "bare")
    decompress       = optional(bool, true)
    min_disk_gb      = optional(number, 10)
  })
  description = <<-EOT
    OPNsense custom image. Når upload = true, uploades imaget til Glance via openstack_images_image_v2,
    og VM'en peger på det. Sæt local_file_path for at uploade en lokal fil i stedet for source_url.
    Bemærk: OPNsense nano-imaget er raw (disk_format = "raw"). decompress = true udpakker .bz2/.gz automatisk.
    Sæt upload = false hvis imaget allerede findes i projektet — så bruges vm_config.image_name som opslag.
  EOT
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the VM"
  default = {
    environment = "test"
    purpose     = "opnsense-firewall"
  }
}
