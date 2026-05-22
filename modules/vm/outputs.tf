output "private_ssh_key" {
  value     = try(tls_private_key.ssh_key[0].private_key_pem, "No SSH key generated")
  sensitive = true
}

output "vm_ip" {
  value       = openstack_compute_instance_v2.VMs.access_ip_v4
  description = "The private IPv4 address of the deployed VM"
}