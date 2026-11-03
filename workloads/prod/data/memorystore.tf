module "redis_service" {
  source                      = "../../../modules/redis"
  cache                       = var.cache
  enable_cache                = var.enable_cache
  labels                      = var.labels
  private_network_self_link   = try(data.google_compute_network.production[0].self_link, null)
  private_services_range_name = try(data.google_compute_global_address.private_services[0].name, var.private_services_range_name)
  project_id                  = var.project_id
  region                      = var.region
  depends_on                  = [module.project_services]
}
