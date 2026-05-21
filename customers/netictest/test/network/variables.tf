## Common variables
variable "ovh_project_id" {}
variable "ovh_region"   { }
variable "ovh_api_region" { }
variable "ovh_project_name" { } 

variable "environment" {}
variable "name_prefix"{} 

## local variables


variable "network" {
  type = object({
    name = string
    vlan = number

    regions = list(object({
    region              = string
    subnet              = string
    dhcp                = optional(bool, true)   # Defaults to true if omitted by the user
    ip_allocation_start = optional(number, 10)   # Defaults to 10 if omitted by the user
    ip_allocation_stop  = optional(number, 200)  # Defaults to 200 if omitted by the user
    }))
  })

  default = {
    name = "net"
    vlan = 1900

    regions = [
      {
        region = "GRA9"
        subnet = "192.168.10.0/24"
      },
      {
        region = "BHS5"
        subnet = "192.168.11.0/24"
      },
      {
        region = "UK1"
        subnet = "192.168.12.0/24"
        dhcp   = false
      }
    ]
  }
}
