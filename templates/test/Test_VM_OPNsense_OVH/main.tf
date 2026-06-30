
# =============================================================================
# Network — OVH private vRack network
# =============================================================================
module "network" {
  source   = "github.com/neticdk-k8s/terraform-netic-cloud-modules//modules/network/network/wrapper"
  for_each = { for net in var.networks : net.name => net }

  network = {
    name = each.value.name

    ovh = {
      project_id = var.cloud_settings.ovh.project_id
      vlan_id    = each.value.vlan_id
      regions    = each.value.regions
    }
  }
}


# =============================================================================
# VM — OPNsense firewall
# =============================================================================

module "vm" {
  source = "github.com/neticdk-k8s/terraform-netic-cloud-modules//modules/vm/wrapper"

  vm = {
    name             = "sshconfig" # var.vm_config.name
    size             = var.vm_config.size
    location         = var.cloud_settings.region
    resource_group   = var.vm_config.resource_group
    os_type          = "Linux"
    ssh_public_key   = null # var.vm_config.ssh_public_key
    create_public_ip = var.vm_config.create_public_ip

    ovh = {
      project_id      = var.cloud_settings.ovh.project_id
      image_name      =  "vpn2_custom" 
      network_names   = [for net in var.networks : net.name]
      security_groups = var.vm_config.security_groups
    }

    tags = var.tags
  }

  depends_on = [module.network]
}

module "vm2" {
  source   = "github.com/neticdk-k8s/terraform-netic-cloud-modules//modules/vm/wrapper"
#  for_each = toset([for i in range(3) : tostring(i + 1)])

  vm = {
    name             = "github" #${each.key}"
    size             = var.vm_config.size
    location         = var.cloud_settings.region
    resource_group   = var.vm_config.resource_group
    os_type          = "Linux"
    ssh_public_key   = null
    create_public_ip = var.vm_config.create_public_ip

    ovh = {
      project_id      = var.cloud_settings.ovh.project_id
      image_name      = "vpn2_custom" # var.test_vm_images[tonumber(each.key) - 1]
      network_names   = [for net in var.networks : net.name]
      security_groups = var.vm_config.security_groups
    }

    tags = var.tags
  }

  depends_on = [module.network]
}


module "vm3" {
  source   = "github.com/neticdk-k8s/terraform-netic-cloud-modules//modules/vm/wrapper"
#  for_each = toset([for i in range(3) : tostring(i + 1)])

  vm = {
    name             = "justplain"
    size             = var.vm_config.size
    location         = var.cloud_settings.region
    resource_group   = var.vm_config.resource_group
    os_type          = "Linux"
    ssh_public_key   = null
    create_public_ip = var.vm_config.create_public_ip

    ovh = {
      project_id      = var.cloud_settings.ovh.project_id
      image_name      = "vpn2_custom" # var.test_vm_images[tonumber(each.key) - 1]
      network_names   = [for net in var.networks : net.name]
      security_groups = var.vm_config.security_groups
    }

    tags = var.tags
  }

  depends_on = [module.network]
}


# =============================================================================
# Metode 1 — Direkte config.xml via Terraform
# =============================================================================
resource "null_resource" "opnsense_config_direct" {
  depends_on = [module.vm]

  connection {
    type     = "ssh"
    host     = module.vm.public_ip
    user     = "root"
    password = "opnsense"
  }

  provisioner "file" {
    source      = "${path.module}/config.xml"
    destination = "/conf/config.xml"
  }

  provisioner "remote-exec" {
    inline = ["nohup sh -c 'sleep 5 && /sbin/reboot' > /dev/null 2>&1 &"]
  }
}


# =============================================================================
# Metode 2 — GitHub bootstrap script (henter config ved næste boot)
# =============================================================================

resource "null_resource" "opnsense_config_github" {
  depends_on = [module.vm2]

  connection {
    type     = "ssh"
    host     = module.vm2.public_ip
    user     = "root"
    password = "opnsense"
  }

  provisioner "file" {
    source      = "${path.module}/../VM_Images_Upload_OVH/99-github-bootstrap"
    destination = "/tmp/99-github-bootstrap"
  }

  provisioner "remote-exec" {
    inline = [
      "cp /tmp/99-github-bootstrap /usr/local/etc/rc.syshook.d/start/99-github-bootstrap",
      "chmod +x /usr/local/etc/rc.syshook.d/start/99-github-bootstrap",
      "nohup sh -c 'sleep 5 && /sbin/reboot' > /dev/null 2>&1 &",
    ]
  }
}
