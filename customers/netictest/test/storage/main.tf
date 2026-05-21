module "storage" {
  source = "../../../../modules/storage"
  deployment_type = "block"
  block_storage = var.block_storage
  ovh_project_id = var.ovh_project_id
}
