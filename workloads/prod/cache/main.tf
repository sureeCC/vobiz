resource "google_redis_instance" "cache" {
  project                 = var.project_id
  region                  = var.region
  name                    = var.cache.name
  memory_size_gb          = var.cache.memory_size_gb
  tier                    = var.cache.tier
  redis_version           = var.cache.redis_version
  authorized_network      = var.network_id
  connect_mode            = "PRIVATE_SERVICE_ACCESS"
  reserved_ip_range       = var.reserved_ip_range
  auth_enabled            = true
  transit_encryption_mode = "SERVER_AUTHENTICATION"
  deletion_protection     = true
  labels                  = var.labels
  maintenance_policy {
    weekly_maintenance_window {
      day = var.cache.maintenance_day
      start_time {
        hours   = var.cache.maintenance_hour_utc
        minutes = 0
        seconds = 0
        nanos   = 0
      }
    }
  }
}
