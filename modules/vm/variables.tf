variable "ovh_project_id" {
  description = "OVH Cloud project ID / service name"
  type        = string
}

variable "vm" {
  type = object({
    name                  = string
    size                  = string
    image_name            = string
    sshkey                = optional(string, null)
    admin_pass            = optional(string, "Password123!")
    network_names         = list(string)               # F.eks. ["reg-vlan-10"] eller ["Ext-Net"]
    power_state           = optional(string, "active") # "active" eller "shutoff"
    user_data             = optional(string, null)     # Bash scripts / cloud-init
    
    # Det generiske netkorts-tweak (IP Forwarding / Anti-spoofing bypass)
    allowed_address_pairs = optional(list(string), []) 
  })
  description = "Generisk konfigurationsobjekt til udrulning af en VM"
}