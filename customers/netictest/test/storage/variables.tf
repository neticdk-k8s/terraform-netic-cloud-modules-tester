## Common variables
variable "ovh_project_id" {}
variable "ovh_region"   { }
variable "ovh_api_region" { }
variable "ovh_project_name" { } 

variable "environment" {}
variable "name_prefix"{} 

# OpenStack
variable "OS_username" {}
variable "OS_password" {}

## local variables



variable "deployment_type" {
  default = "block"
  type        = string
}

variable "object_storage" {
  description = "Object storage config (used when deployment_type = object)"
  type = object({
    name             = string
    region           = string
    versioning       = optional(string, "enabled")
    encryption_sse   = optional(string, "AES256")
    object_lock_days = optional(number, 0)
  })

  default = {
    name             = "object-test-storage"
    region           = "GRA"
    versioning       = "enabled"
    encryption_sse   = "AES256"
    object_lock_days = 0
  }
}

variable "block_storage" {
  description = "Block storage config (used when deployment_type = block)"
  type = object({
    name                 = string
    region               = string
    size                 = optional(number, 10)
    volume_type          = optional(string, "classic")
    description         = optional(string, "Storage")
    enable_online_resize = optional(bool, false)
    volume_retype_policy = optional(string, "never")
  })

  default = {
    name                 = "block-test-storage"
    region               = "GRA9"  ## Openstack and OVH Clouds not the same
                                   ## Download openrc.sh from user in OVHCloud and run with 'source openrc.sh' to login
                                   ## Run openstack catalog show <name> and look for endpoints locations
    size                 = 10
    volume_type          = "classic"
    description          = "Storage"
    enable_online_resize = false
    volume_retype_policy = "never"
  }
}