module "secret_manager" {
  source           = "../../../modules/secret-manager"
  labels           = var.labels
  project_id       = var.project_id
  secret_accessors = var.secret_accessors
  secret_names     = var.secret_names
}
