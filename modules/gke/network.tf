data "google_compute_network" "production" {
  project = var.project_id
  name    = var.network_name
}
data "google_compute_subnetwork" "private" {
  project = var.project_id
  region  = var.region
  name    = var.subnetwork_name
}
