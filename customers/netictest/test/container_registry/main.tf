
module "container_registry" {
  source = "../../../../modules/container_registry"
  
  ovh_project_id     = var.ovh_project_id
  container_registry = var.container_registry
}
