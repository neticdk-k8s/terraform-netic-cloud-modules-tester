# Example of referencing a network resource (uncomment and adjust if needed)
# data "ovh_cloud_project_network_private" "net" {
#   service_name = var.ovh_project_id
#   name         = var.private_network_name
# }

module "control_plane" {
  source = "./modules/vm"
  count        = var.VMcount
  network_name = var.private_network_name # Or: data.ovh_cloud_project_network_private.net.name
  vm           = var.ControlPlaneVM
}
