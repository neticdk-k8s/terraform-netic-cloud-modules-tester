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

variable "VMcount" {
  type    = number
  default = 2
}

variable "ControlPlaneVM" {
  type = object({
    name                     = string
    size                     = string
    image_name               = string
    sshkey                   = optional(string, null)
    admin_pass               = optional(string, "Password123!")
    network_names            = optional(list(string), []) 
    power_state              = optional(string, "active")
  })
  default = {
    name                     = "netic-cp"
    size                     = "b2-7"
    image_name               = "Ubuntu 24.04"
    network_names            = [ "netic-net-test" ]
  }
}
