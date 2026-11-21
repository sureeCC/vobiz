locals {
  platform_apis = toset(concat(
    length(var.ingress_rules) + length(var.egress_rules) > 0 || var.delete_default_internet_gateway_routes ? ["compute.googleapis.com"] : [],
    length(var.repositories) > 0 ? ["artifactregistry.googleapis.com"] : [],
    length(var.secrets) > 0 ? ["secretmanager.googleapis.com"] : [],
    var.cache != null ? ["redis.googleapis.com", "compute.googleapis.com", "servicenetworking.googleapis.com"] : [],
    var.private_service_access_config.enable_private_services_connection ? ["compute.googleapis.com", "servicenetworking.googleapis.com"] : []
  ))
}
resource "google_project_service" "platform" {
  for_each           = local.platform_apis
  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}
module "registry" {
  source       = "./registry"
  project_id   = var.project_id
  region       = var.region
  labels       = var.labels
  repositories = var.repositories
  depends_on   = [google_project_service.platform]
}
module "secrets" {
  source     = "./secrets"
  project_id = var.project_id
  region     = var.region
  labels     = var.labels
  secrets    = var.secrets
  depends_on = [google_project_service.platform]
}
module "cache" {
  count             = var.cache == null ? 0 : 1
  source            = "./cache"
  project_id        = var.project_id
  region            = var.region
  labels            = var.labels
  cache             = var.cache
  network_id        = module.networking.network_id
  reserved_ip_range = var.private_service_access_config.address_name
  depends_on        = [google_project_service.platform, module.networking]
}
