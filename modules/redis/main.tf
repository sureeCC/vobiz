module "redis" {
  count   = var.enable_cache ? 1 : 0
  source  = "terraform-google-modules/memorystore/google"
  version = "16.4.1"

  project_id              = var.project_id
  region                  = var.region
  name                    = var.cache.name
  memory_size_gb          = var.cache.memory_size_gb
  redis_version           = var.cache.redis_version
  tier                    = "STANDARD_HA"
  authorized_network      = var.private_network_self_link
  connect_mode            = "PRIVATE_SERVICE_ACCESS"
  reserved_ip_range       = var.private_services_range_name
  auth_enabled            = true
  transit_encryption_mode = "SERVER_AUTHENTICATION"
  labels                  = var.labels
  enable_apis             = false

}
