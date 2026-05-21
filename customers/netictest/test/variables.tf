variable "OS_user" {}
variable "OS_password" {}

variable "ovh_region" {}
variable "ovh_project_name" {}
variable "ovh_project_id" {}
variable "ovh_application_key" {}
variable "ovh_application_secret" {}
variable "ovh_consumer_key" {}
variable "ovh_tenantid" {}
variable "ovh_api_region" {}



######################################
###          Storage               ###
######################################

variable "storage" {
  type = object({
    name       = string
    region     = string
    regions    = list(string)
    versioning = string
  })
  default = {
    name       = "storage"
    region     = "GRA9"
    regions    = ["GRA9", "BHS5", "UK1"]
    versioning = "enabled" //  ["disabled" "enabled" "suspended"]

  }
}


######################################
###          Networks              ###
######################################

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
    name = "vnet"
    vlan = 1800

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
###   Private Container Registry   ###
######################################

variable "ContainerRegistry" {
  type = object({
    deploy = bool
    name   = string
    region = string

  })
  default = {
    deploy = true
    name   = "my-docker-private-registry"
    region = "DE"
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

