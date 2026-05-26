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
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), []) # RETTET: Ændret fra null til []
  })
  description = "Konfigurationsobjekt for det Managed Kubernetes Cluster"

  default = {
    deploy          = true
    name            = "netic-k8s-test"
    version         = "1.30"
    size            = "b2-7"
    nodes_count     = 1
    nodes_min       = 1
    nodes_max       = 3
    labels          = { env = "test", managed-by = "terraform" }
    ip_restrictions = []
    taints          = []
  }
}
