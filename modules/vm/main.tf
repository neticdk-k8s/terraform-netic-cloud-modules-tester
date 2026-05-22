locals {
  # Check if the word "windows" exists in the image name (case-insensitive using (?i))
  is_windows = can(regex("(?i)windows", var.vm.image_name))
  
  # Only generate SSH key if enable_ssh_key is true AND the OS is NOT Windows
  create_ssh_key = var.vm.enable_ssh_key && !local.is_windows
}

######################################
###          SSH Key Section       ###
######################################

# Generate SSH keypair (conditional based on OS/override)
resource "tls_private_key" "ssh_key" {
  count     = local.create_ssh_key ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save the private key locally
resource "local_file" "private_key" {
  count           = local.create_ssh_key ? 1 : 0
  filename        = "${path.root}/${var.vm.name}_id_rsa"
  content         = tls_private_key.ssh_key[0].private_key_pem
  file_permission = "0600"
}

# Upload the public key to OVH/OpenStack
resource "openstack_compute_keypair_v2" "default" {
  count      = local.create_ssh_key ? 1 : 0
  name       = "${var.vm.name}-key"
  public_key = tls_private_key.ssh_key[0].public_key_openssh
}

######################################
###          Generate VMs          ###
######################################

# Main VM instance
resource "openstack_compute_instance_v2" "VMs" {
  name            = "${var.vm.name}"
  flavor_name     = var.vm.size
  image_name      = var.vm.image_name
  
  key_pair        = local.create_ssh_key ? openstack_compute_keypair_v2.default[0].name : null
  security_groups = ["default"]

  network {
    name = var.network_name
  }

  lifecycle {
    ignore_changes = [image_name]
  }
}

# Optional Public Windows VM
resource "openstack_compute_instance_v2" "VMPublicNet" {
  count           = var.vm.create_public_windows_vm ? 1 : 0
  name            = "publicnet-${var.vm.name}"
  flavor_name     = var.vm.size
  image_name      = "Windows Server 2025 Standard (Desktop)"
  admin_pass      = "Password123!"
  security_groups = ["default"]

  network {
    name = var.network_name
  }
  network {
    name = "Ext-Net"
  }

  lifecycle {
    ignore_changes = [image_name]
  }
}