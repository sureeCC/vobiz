module "registry" {
  source       = "../../../modules/artifact-registry"
  project_id   = var.project_id
  repositories = var.repositories
  region       = var.region
  depends_on   = [google_project_service.required]
}
