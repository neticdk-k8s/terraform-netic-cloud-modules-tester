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

## Kubernetes Variables

variable "ManagedKMSCluster" {
  type = object({
    deploy          = bool
    name            = string
    version         = string
    ip_restrictions = optional(list(string), [])
  })
  description = "Configuration of the K8s cluster"

  default = {
    deploy          = true
    name            = "netic-k8s-test"
    version         = "1.34"
    ip_restrictions = []
  }
}

variable "ManagedKMSNodePools" {
  type = map(object({
    size        = string
    nodes_count = number
    nodes_min   = number
    nodes_max   = number
    labels      = optional(map(string), {})
    taints      = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
  }))
  description = "Map of nodepools.  You can add more pools"

  default = {
    "default-pool" = {
      size        = "b2-7"
      nodes_count = 1
      nodes_min   = 1
      nodes_max   = 3
      labels      = { env = "test", managed-by = "terraform" }
      taints      = []
    }
  }
}