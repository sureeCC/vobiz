module "artifact_registry" {
  source       = "../../../modules/artifact-registry"
  labels       = var.labels
  project_id   = var.project_id
  region       = var.region
  repositories = var.repositories
}
