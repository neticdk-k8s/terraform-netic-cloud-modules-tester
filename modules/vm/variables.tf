variable "vm" {
  type = object({
    name                     = string
    size                     = string
    image_name               = string
    sshkey                   = optional(string, null)           // For Linux images.  If not provided, one is generated
    admin_pass               = optional(string,"Password123!")  // For Windows images
    network_names            = optional(list(string), []) 

    power_state              = optional(string, "active")       // "shutoff", "paused", "shelved_offloaded"
    user_data                = optional(string, null)           // For scripts
  })
  description = "Combined configuration object for the virtual machine"
}