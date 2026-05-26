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
    name = "netic-vpn-net"
    vlan = 1900

    regions = [
      {
        region = "GRA9"
        subnet = "192.168.10.0/24"
      }
    ]
  }
}


variable "vpn_vm" {
  type = object({
    name          = string
    size          = string
    image_name    = string
    sshkey        = optional(string, null)
    admin_pass    = optional(string, "Password123!")
    network_names = optional(list(string), [])
    power_state   = optional(string, "active")
    user_data     = optional(string, null)           // For scripts

  })
default = {
    name          = "netic-vpn"
    size          = "b2-7"
    image_name    = "Ubuntu 24.04"
    network_names = ["netic-vpn-net", "Ext-Net"]
    
    user_data     = <<-EOT
      #!/bin/bash
      # 1. Permanent aktivering af IP forwarding i sysctl
      echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
      
      # 2. Genindlæs sysctl så det træder i kraft med det samme
      sysctl -p
      
      # 3. Valgfrit: Installer stærke netværksværktøjer eller vpn med det samme
      apt-get update
      apt-get install -y strongswan iptables-persistent
    EOT
  }
}