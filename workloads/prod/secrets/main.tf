module "secrets" {
  source     = "../../../modules/secret-manager"
  project_id = var.project_id
  secrets    = var.secrets
  region     = var.region
  depends_on = [google_project_service.required]
}
