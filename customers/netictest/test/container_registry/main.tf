
module "container_registry" {
  source = "../../../../modules/container_registry"
  
  project_id         = var.ovh_project_id
  container_registry = var.container_registry
}
