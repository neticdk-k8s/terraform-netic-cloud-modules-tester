# List available images :
#   export OS_REGION_NAME=GRA9
#   openstack image list --public    or 
#   openstack image list --public | grep -i "2025"

# List available flavors (sizes)
#   openstack --os-region-name GRA9 flavor list

## Common variables
variable "ovh_project_id" {}
variable "ovh_region" {}
variable "ovh_api_region" {}
variable "ovh_project_name" {}

variable "environment" {}
variable "name_prefix" {}

# OpenStack
variable "OS_username" {}
variable "OS_password" {}


## local variables

variable "ControlPlaneVM_VMCount" {
  type    = number
  default = 1
}

variable "ControlPlaneVM" {
  type = object({
    name          = string
    size          = string
    image_name    = string
    sshkey        = optional(string, null)
    admin_pass    = optional(string, "Password123!")
    network_names = optional(list(string), [])
    power_state   = optional(string, "active")
    user_data                = optional(string, null)           // For scripts
  })
  default = {
    name          = "netic-cp"
    size          = "b2-7"
    image_name    = "Ubuntu 24.04"
    network_names = ["netic-net-test"]
  }
}

variable "WindowsVM" {
  type = object({
    name          = string
    size          = string
    image_name    = string
    sshkey        = optional(string, null)
    admin_pass    = optional(string, "Password123!")
    network_names = optional(list(string), [])
    power_state   = optional(string, "active")
  })
  default = {
    name          = "netic-win"
    size          = "b2-7"
    image_name    = "Windows Server 2025 Standard (Desktop)"
    network_names = ["netic-net-test"]
  }
}
