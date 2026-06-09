output "network_id" {
  description = "ID på det oprettede VNet"
  value       = module.network.network_id
}

output "subnet_ids" {
  description = "Map af subnet-navne til subnet-IDs"
  value       = module.network.subnet_ids
}
