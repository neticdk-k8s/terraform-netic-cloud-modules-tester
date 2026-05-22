variable "vm" {
  type = object({
    name                     = string
    size                     = string
    image_name               = string
    enable_ssh_key           = optional(bool, true)  # Defaults to true if omitted
    create_public_windows_vm = optional(bool, false) # Defaults to false if omitted
  })
  description = "Combined configuration object for the virtual machine"
}

variable "network_name" {
  type        = string
  description = "The name of the target private network"
}
