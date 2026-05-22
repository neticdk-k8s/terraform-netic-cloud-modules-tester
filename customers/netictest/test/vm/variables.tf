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
  default = 1
}

variable "private_network_name" {
  type        = string
  description = "The name of the private network to attach the VMs to"
  default     = "netic-net-test"
}

variable "ControlPlaneVM" {
  type = object({
    name                     = string
    size                     = string
    image_name               = string
    enable_ssh_key           = optional(bool, true)  # Defaults to true if omitted
    create_public_windows_vm = optional(bool, false) # Defaults to false if omitted
  })
  default = {
    name                     = "netic-cp"
    size                     = "b2-7"
    image_name               = "Ubuntu 24.04"
    enable_ssh_key           = true
    create_public_windows_vm = false
  }
}

