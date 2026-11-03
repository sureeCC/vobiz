provider "google" {
  project                     = var.project_id
  region                      = var.region
  impersonate_service_account = var.impersonate_service_account
  default_labels              = var.labels
}
provider "google-beta" {
  project                     = var.project_id
  region                      = var.region
  impersonate_service_account = var.impersonate_service_account
  default_labels              = var.labels
}
