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

variable "ManagedKMSCluster" {
  type = object({
    deploy          = bool
    name            = string
    version         = string
    size            = string
    nodes_count     = number
    nodes_min       = number
    nodes_max       = number
    labels          = optional(map(string), {})
    ip_restrictions = optional(list(string), [])
    taints          = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), null)
  })
  default = {
    deploy          = true
    name            = "netic-k8s-test"
    version         = "1.30"            
    size            = "b2-7"            # Den standard general-purpose størrelse, du har brugt før
    nodes_count     = 1                 # Starter billigt ud med 1 enkelt node i test
    nodes_min       = 1                 # Kan autoskalere ned til 1 node
    nodes_max       = 3                 # Maksimalt 3 noder i test for at holde budgettet lukket
    labels          = { env = "test", managed-by = "terraform" }
    ip_restrictions = []                # Åben som standard i test, medmindre andet angives
    taints          = null              # Ingen taints som standard i test
  }
}