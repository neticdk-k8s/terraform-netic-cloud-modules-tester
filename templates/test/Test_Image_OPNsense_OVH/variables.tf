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

variable "image_config" {
  type = object({
    name             = optional(string, "OPNsense")
    source_url       = optional(string, "https://mirror.dns-root.de/opnsense/releases/25.1/OPNsense-25.1-nano-amd64.img.bz2")
    local_file_path  = optional(string, null)
    disk_format      = optional(string, "raw")
    container_format = optional(string, "bare")
    decompress       = optional(bool, true)
    min_disk_gb      = optional(number, 10)
  })
  description = <<-EOT
    OPNsense custom image. Uploades til Glance via openstack_images_image_v2.
    Sæt local_file_path for at uploade en lokal fil i stedet for source_url.
    Bemærk: OPNsense nano-imaget er raw (disk_format = "raw"). decompress = true udpakker .bz2/.gz automatisk.
  EOT
  default     = {}
}
