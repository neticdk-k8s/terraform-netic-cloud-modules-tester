
# =============================================================================
# Image — upload OPNsense til Glance (OVH har ikke et stock OPNsense-image)
#
# Denne template har sin EGEN state og uploader kun imaget. Kør den én gang,
# og brug derefter image_name = "OPNsense" i Test_VM_OPNsense_OVH, så VM'en
# slår imaget op på navn. På den måde overlever imaget gentagne destroy af VM/net.
# =============================================================================
resource "openstack_images_image_v2" "opnsense" {
  name             = var.image_config.name
  image_source_url = var.image_config.local_file_path == null ? var.image_config.source_url : null
  local_file_path  = var.image_config.local_file_path
  decompress       = var.image_config.decompress
  disk_format      = var.image_config.disk_format
  container_format = var.image_config.container_format
  min_disk_gb      = var.image_config.min_disk_gb
  visibility       = "private"

  properties = {
    os_type = "linux"
  }
}
