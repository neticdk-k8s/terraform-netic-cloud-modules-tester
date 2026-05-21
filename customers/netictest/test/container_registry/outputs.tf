output "registry_url" {
  value       = module.container_registry.registry_url
  description = "The public URL endpoint of the provisioned Container Registry"
}

# Returns a map with users
output "registry_user_passwords" {
  value       = module.container_registry.user_passwords
  sensitive   = true
  description = "Map of registry usernames and their generated passwords provided by the module"
}