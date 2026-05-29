// Best way is to deploy a OVHCloud Connect (like expressroute) to fx 
// OCC Direct - Germany - Equinox FR-5
// Expressroute til FR-5
// https://www.ovhcloud.com/en/network/ovhcloud-connect/
// https://docs.ovhcloud.com/en/guides/network/ovhcloud-connect/occ-provider-control-panel



resource "openstack_networking_floatingip_v2" "fip" {
  pool  = "Ext-Net"
}

module "network" {
  source         = "../../../../modules/network"
  ovh_project_id = var.ovh_project_id
  network_name   = var.network.name
  vlan_id        = var.network.vlan
  regions        = var.network.regions
}

module "vpnvm" {
  source         = "../../../../modules/vm"
  ovh_project_id = var.ovh_project_id

  # Vi opdaterer 'user_data' dynamisk med værdier før modulet køres
  vm = merge(var.vpn_vm, {
    # Fortæl modulet at det skal bruge den IP, vi lige har oprettet herude i roden
    bind_existing_fip = openstack_networking_floatingip_v2.fip[0].address

    user_data = templatefile("${path.module}/userdata.sh.tpl", {
      ovh_subnet   = var.network.regions[0].subnet # Svarer til: "192.168.10.0/24"
      azure_ip     = var.azure_vpn_gateway_ip      # Standard Public IP fra Azure VPN GW
      azure_subnet = var.azure_vnet_subnet_cidr    # Svarer til: "192.168.24.0/22"
      azure_psk    = var.azure_vpn_secret          # Din Pre-Shared Key
      azure_psk    = var.azure_vpn_secret          # Din Pre-Shared Key
    })
  })

  depends_on = [module.network]
}


module "testvm" {
  source         = "../../../../modules/vm"
  ovh_project_id = var.ovh_project_id

  vm = var.testvm

  depends_on = [module.network]
}
