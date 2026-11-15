module "cache" {
  source               = "../../../modules/redis"
  project_id           = var.project_id
  region               = var.region
  name                 = var.name
  network_id           = var.network_id
  memory_size_gb       = var.memory_size_gb
  tier                 = var.tier
  redis_version        = var.redis_version
  connect_mode         = var.connect_mode
  reserved_ip_range    = var.reserved_ip_range
  maintenance_day      = var.maintenance_day
  maintenance_hour_utc = var.maintenance_hour_utc
  depends_on           = [google_project_service.required]
}
