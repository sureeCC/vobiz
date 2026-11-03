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
module "data_apis" {
  source     = "terraform-google-modules/project-factory/google//modules/project_services"
  version    = "18.4.0"
  project_id = var.project_id
  activate_apis = concat(
    var.enable_sql ? ["sqladmin.googleapis.com"] : [],
    var.enable_cache ? ["redis.googleapis.com"] : []
  )
  disable_services_on_destroy = false
  disable_dependent_services  = false
}
