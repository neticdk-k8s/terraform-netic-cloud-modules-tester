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




######################################
###      VMs for Kubernetes        ###
######################################

variable "ControlPlaneVM" {
  type = object({
    name_prefix = string
    size        = string
    image_name  = string
    count       = number
  })
  default = {
    name_prefix = "vm-worker"
    size        = "d2-2"
    image_name  = "Ubuntu 24.04"
    count       = 1
  }
}


######################################
###   Managed Kubernetes Cluster   ###
######################################
variable "ManagedKMSCliuster" {
  type = object({
    deploy      = bool
    name        = string
    size        = string
    image_name  = string
    version     = string
    nodes_count = number
    nodes_min   = number
    nodes_max   = number
  })
  default = {
    deploy      = false
    name        = "kms-cluster" //Warning: "_" char is not allowed!
    size        = "d2-4"        // "b2-7". # B = general purpose, D = dicover(test), T2-45 = GPU
    image_name  = "Ubuntu 24.04"
    version     = "1.35"
    nodes_count = 1
    nodes_min   = 1
    nodes_max   = 3
  }
}

######################################
###            Identities         ###
######################################
variable "users" {
  type = object({
    default_password = string
    accounts = list(object({
      login       = string
      email       = string
      group       = optional(string)
      description = optional(string)
    }))
  })

  default = {
    default_password = "Secret123"
    accounts = [
      {
        login       = "jens"
        email       = "e@e.ee"
        group       = "netic-write"
        description = "Netic write user"
      },
      {
        login       = "anna"
        email       = "a@a.ee"
        group       = "netic-read"
        description = "Netic reader user"
      },
      {
        login       = "josef"
        email       = "j@a.ee"
        group       = "netic-admin"
        description = "Netic admin user"
      },
      {
        login = "mona"
        email = "m@a.ee"
      }
    ]
  }
}

variable "iam_groups" {
  type    = list(string)
  default = ["netic-read", "netic-write", "netic-admin"]
}

######################################
###            KeyVault            ###
######################################

// Please note, that a rename of display name can occur, resulting in two OKMS Domains. 
// API provider issue...
variable "keyvault" {
  type = object({
    deploy    = bool
    name      = string
    region    = string
    subsidary = string
  })
  default = {
    deploy    = false
    name      = "kms-cluster2"
    subsidary = "ca"
    region    = "ca-east-bhs"
  }
}

