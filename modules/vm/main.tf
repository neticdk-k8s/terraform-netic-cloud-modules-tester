# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/compute_instance_v2

# Networks accessable : 'openstack network list'
locals {
  # Check if the word "windows" exists in the image name (case-insensitive using (?i))
  is_windows = can(regex("(?i)windows", var.vm.image_name))

  # Generate a new SSH key ONLY if no existing key is provided AND it is NOT a Windows VM
  create_ssh_key = var.vm.sshkey == null && !local.is_windows
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

# Save private key locally (conditional)
resource "local_file" "private_key" {
  count           = local.create_ssh_key ? 1 : 0
  filename        = "${path.root}/${var.vm.name}_id_rsa"
  content         = tls_private_key.ssh_key[0].private_key_pem
  file_permission = "0600"
}
/*
## This is only relevant when running from terminal
## When using github, we dont have direct access, except from statefil
# Upload public key to OVH/OpenStack (conditional) (next step)
resource "openstack_compute_keypair_v2" "default" {
  count      = local.create_ssh_key ? 1 : 0
  name       = "${var.vm.name}-generated-key"
  public_key = tls_private_key.ssh_key[0].public_key_openssh
}
*/

resource "ovh_cloud_project_ssh_key" "default" {
  count        = local.create_ssh_key ? 1 : 0
  service_name = var.ovh_project_id  # Dit projekt-ID fra variablen
  name         = "${var.vm.name}-generated-key"
  public_key   = tls_private_key.ssh_key[0].public_key_openssh
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
