output "image_id" {
  description = "Glance image ID"
  value       = openstack_images_image_v2.opnsense.id
}

output "image_name" {
  description = "Image name — brug denne som vm_config.image_name i Test_VM_OPNsense_OVH"
  value       = openstack_images_image_v2.opnsense.name
}
