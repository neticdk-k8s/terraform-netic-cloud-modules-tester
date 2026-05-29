# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/compute_instance_v2

# Networks accessable : 'openstack network list'
locals {
  # Check if the word "windows" exists in the image name (case-insensitive using (?i))
  is_windows = can(regex("(?i)windows", var.vm.image_name))

  # Generate a new SSH key ONLY if no existing key is provided AND it is NOT a Windows VM
  create_ssh_key = var.vm.sshkey == null && !local.is_windows
  
  ## For Floating IP
  # Get id of relevant VM created
   instance_id = local.is_windows ? one(openstack_compute_instance_v2.VMWindows[*].id) : one(openstack_compute_instance_v2.VMLinux[*].id)
   has_floating_ip = var.vm.create_floating_ip || var.vm.existing_fip != null

}


######################################
###          SSH Key Section       ###
######################################

# Generate SSH keypair (conditional)
resource "tls_private_key" "ssh_key" {
  count     = local.create_ssh_key ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

/*
## This is only relevant when running from terminal
## When using github, we dont have direct access, except from statefil
# Save private key locally (conditional)
resource "local_file" "private_key" {
  count           = local.create_ssh_key ? 1 : 0
  filename        = "${path.root}/${var.vm.name}_id_rsa"
  content         = tls_private_key.ssh_key[0].private_key_pem
  file_permission = "0600"
}

*/

# Upload public key to OVH/OpenStack (conditional) (next step)
resource "openstack_compute_keypair_v2" "default" {
  count      = local.create_ssh_key ? 1 : 0
  name       = "${var.vm.name}-generated-key"
  public_key =  trimspace(tls_private_key.ssh_key[0].public_key_openssh) // Removes \n at the end of ssh
}

resource "ovh_cloud_project_ssh_key" "default" {
  count        = local.create_ssh_key ? 1 : 0
  service_name = var.ovh_project_id  
  name         = "${var.vm.name}-generated-key"
  // public_key   = tls_private_key.ssh_key[0].public_key_openssh
  public_key   = trimspace(tls_private_key.ssh_key[0].public_key_openssh) // Removes \n at the end of ssh
}

######################################
###          Generate VMs          ###
######################################

# Main VM instance
resource "openstack_compute_instance_v2" "VMLinux" {
  count       = local.is_windows ? 0 : 1
  name        = var.vm.name
  flavor_name = var.vm.size
  image_name  = var.vm.image_name

  // key_pair     = local.create_ssh_key ? openstack_compute_keypair_v2.default[0].name : var.vm.sshkey
  key_pair        = local.create_ssh_key ? ovh_cloud_project_ssh_key.default[0].name : var.vm.sshkey
  // key_pair        = local.create_ssh_key ? one(openstack_compute_keypair_v2.default[*].name) : var.vm.sshkey  // Refeer to openstack, as we get error 400 when using ovhref
  security_groups = ["default"]

  power_state     = var.vm.power_state

  user_data       = var.vm.user_data
  
  dynamic "network" {
    for_each = var.vm.network_names
    content {
      name = network.value
    }
  }

  lifecycle {
    ignore_changes = [image_name]
  }

  depends_on = [ ovh_cloud_project_ssh_key.default ]
}


resource "openstack_compute_instance_v2" "VMWindows" {
  count           = local.is_windows ? 1 : 0
  name            = var.vm.name
  flavor_name     = var.vm.size
  image_name      = var.vm.image_name
  admin_pass      = var.vm.admin_pass
  security_groups = ["default"]

  power_state     = var.vm.power_state
  
  dynamic "network" {
    for_each = var.vm.network_names
    content {
      name = network.value
    }
  }

  lifecycle {
    ignore_changes = [image_name]
  }
}


######################################
###      Floating IP Sektion       ###
######################################

# Opretter KUN en IP, hvis modulet selv skal stå for det
resource "openstack_networking_floatingip_v2" "fip" {
  count = var.vm.create_floating_ip ? 1 : 0
  pool  = "Ext-Net" 
}

# Slår netværksporten op på din VM
data "openstack_networking_port_v2" "vm_port" {
  count     = local.has_floating_ip ? 1 : 0
  device_id = local.instance_id
}

# Binder IP'en (Uanset om den er ny eller eksisterende)
resource "openstack_networking_floatingip_associate_v2" "fip_assoc" {
  count       = local.has_floating_ip ? 1 : 0
  port_id     = data.openstack_networking_port_v2.vm_port[0].id
  floating_ip = var.vm.existing_fip != null ? var.vm.existing_fip : openstack_networking_floatingip_v2.fip[0].address
}

# VIGTIGT: Vi scannner port-id'et ud af modulet, så roden kan se det (vises i næste skridt)
output "primary_port_id" {
  value = local.has_floating_ip ? data.openstack_networking_port_v2.vm_port[0].id : null
}