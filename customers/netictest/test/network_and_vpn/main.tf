// Best way is to deploy a OVHCloud Connect (like expressroute) to fx 
// OCC Direct - Germany - Equinox FR-5
// Expressroute til FR-5
// https://www.ovhcloud.com/en/network/ovhcloud-connect/
// https://docs.ovhcloud.com/en/guides/network/ovhcloud-connect/occ-provider-control-panel


# 1. Opretter din faste offentlige Floating IP i OVH-roden
resource "openstack_networking_floatingip_v2" "fip" {
  pool = "Ext-Net"
}

# 2. Netværksmodul (vRack, subnets osv.)
module "network" {
  source         = "../../../../modules/network"
  ovh_project_id = var.ovh_project_id
  network_name   = var.network.name
  vlan_id        = var.network.vlan
  regions        = var.network.regions
}

# 3. Din VPN VM (Konfigureres som Gateway vha. allowed_address_pairs)
module "vpnvm" {
  source         = "../../../../modules/vm"
  ovh_project_id = var.ovh_project_id

  # Vi merger dynamic userdata OG IP-forwarding (allowed_address_pairs) ind i objektet
  vm = merge(var.vpn_vm, {
    
    # DETTE DEAKTIVERER PORT SECURITY FOR AZURE-TRAFIK INDE I MODULET:
    allowed_address_pairs = [var.azure_vnet_subnet_cidr]

    user_data = templatefile("${path.module}/userdata.sh.tpl", {
      ovh_subnet   = var.network.regions[0].subnet 
      azure_ip     = var.azure_vpn_gateway_ip      
      azure_subnet = var.azure_vnet_subnet_cidr    
      azure_psk    = var.azure_vpn_secret          
    })
  })

  depends_on = [module.network]
}

# 4. Binder din Floating IP direkte til det netkort, som dit VM-modul har oprettet
resource "openstack_networking_floatingip_associate_v2" "fip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.fip.address
  port_id     = module.vpnvm.primary_port_id
}

# 5. Din helt almindelige test-VM (Helt standard adfærd uden netværks-tweaks)
module "testvm" {
  source         = "../../../../modules/vm"
  ovh_project_id = var.ovh_project_id

  vm = var.testvm

  depends_on = [module.network]
}