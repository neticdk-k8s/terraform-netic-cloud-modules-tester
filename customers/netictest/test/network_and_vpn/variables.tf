# Common variables
variable "ovh_project_id" { type = string }
variable "ovh_region" { type = string }
variable "ovh_api_region" { type = string }
variable "ovh_project_name" { type = string }

variable "environment" { type = string }
variable "name_prefix" { type = string }

# OpenStack 
variable "OS_username" { type = string }
variable "OS_password" { type = string }

## Network Configuration
variable "network" {
  type = object({
    name = string
    vlan = number

    regions = list(object({
      region              = string
      subnet              = string
      dhcp                = optional(bool, true)
      ip_allocation_start = optional(number, 10)
      ip_allocation_stop  = optional(number, 200)
    }))
  })

  default = {
    name = "netic-vpn-net"
    vlan = 1901
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
    user_data     = optional(string, null) # Udfyldes dynamisk i main.tf
  })
  default = {
    name          = "netic-vpn"
    size          = "b2-7"
    image_name    = "Ubuntu 24.04"
    network_names = ["netic-vpn-net", "Ext-Net"]
  }
}


variable "testvm" {
  type = object({
    name          = string
    size          = string
    image_name    = string
    sshkey        = optional(string, null)
    admin_pass    = optional(string, "Password123!")
    network_names = optional(list(string), [])
    power_state   = optional(string, "active")
    user_data     = optional(string, null) 
  })
  default = {
    name          = "netic-vpn"
    size          = "b2-7"
    image_name    = "Ubuntu 24.04"
    network_names = ["netic-vpn-net"]
    user_data = "echo 'ubuntu:Kodeord1' | chpasswd"
  }
}

## Azure VPN specifikke input (Sættes f.eks. i din terraform.tfvars eller GitHub Secrets)
variable "azure_vpn_gateway_ip" {
  type        = string
  description = "Den offentlige IP på Azures Virtual Network Gateway"
  default     = "9.205.169.16"
}

variable "azure_vnet_subnet_cidr" {
  type        = string
  description = "Subnettet i Azure som OVH skal kunne route til (f.eks. 10.100.0.0/16)"
  default = "192.168.24.0/22"
}

variable "azure_vpn_secret" {
  type        = string
  sensitive   = true
  description = "Pre-Shared Key (PSK) / Shared Secret fra din Azure VPN opsætning"
  default = "123456"
}