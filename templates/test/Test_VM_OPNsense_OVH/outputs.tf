
output "vm_name" {
  description = "Name of the OPNsense VM"
  value       = module.vm.vm_name
}

output "vm_ip" {
  description = "Primary private IPv4 address"
  value       = module.vm.vm_ip
}

output "public_ip" {
  description = "Public IP address (null if create_public_ip = false)"
  value       = module.vm.public_ip
}

output "ssh_private_key" {
  description = "Generated SSH private key in PEM format (null if a key was provided)"
  value       = module.vm.ssh_private_key
  sensitive   = true
}

/*
output "vm2_ip" {
  description = "Primary private IPv4 address"
  value       = module.vm2.vm_ip
}


output "ssh_private_key2" {
  description = "Generated SSH private key in PEM format (null if a key was provided)"
  value       = module.vm2.ssh_private_key
  sensitive   = true
}
*/