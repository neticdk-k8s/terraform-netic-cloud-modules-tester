variable "kube_cluster" {
  type = object({
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
    })), []) 
  })
}