// Best way is to deploy a OVHCloud Connect (like expressroute) to fx 
// OCC Direct - Germany - Equinox FR-5
// Expressroute til FR-5
// https://www.ovhcloud.com/en/network/ovhcloud-connect/
// https://docs.ovhcloud.com/en/guides/network/ovhcloud-connect/occ-provider-control-panel

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
    user_data = templatefile("${path.module}/userdata.sh.tpl", {
      ovh_subnet   = var.network.regions[0].subnet
      azure_ip     = var.azure_vpn_gateway_ip
      azure_subnet = var.azure_vnet_subnet_cidr
      azure_psk    = var.azure_vpn_secret
    })
  })

  depends_on = [module.network]
}