data "google_compute_network" "production" {
  count   = var.enable_sql || var.enable_cache ? 1 : 0
  project = var.project_id
  name    = var.network_name
}
data "google_compute_global_address" "private_services" {
  count   = var.enable_sql || var.enable_cache ? 1 : 0
  project = var.project_id
  name    = var.private_services_range_name
}
