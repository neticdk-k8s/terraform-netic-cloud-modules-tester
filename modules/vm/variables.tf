variable "ovh_project_id" {
  description = "OVH Cloud project ID / service name"
  type        = string
}

variable "vm" {
  type = object({
    name                     = string
    size                     = string
    image_name               = string
    sshkey                   = optional(string, null)           // For Linux images.  If not provided, one is generated
    admin_pass               = optional(string,"Password123!")  // For Windows images
    network_names            = optional(list(string), [])       // If Ext-Net is in list, a Public IP is assigned on a public network
                                                                // If Floating_Ip se selected, a NAT is created towards the Private IP
                                                                // !!! You CANT have both !!!

    power_state              = optional(string, "active")       // "shutoff", "paused", "shelved_offloaded"
    user_data                = optional(string, null)           // For scripts
    
    create_floating_ip       = optional(bool, false)            // See comment in network_names
    existing_fip             = optional(string, null)           // If using existing FIP, reference this
    
  })
  description = "Combined configuration object for the virtual machine"
}