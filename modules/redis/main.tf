resource "google_redis_instance" "cache" {
  project                 = var.project_id
  region                  = var.region
  name                    = var.name
  tier                    = var.tier
  memory_size_gb          = var.memory_size_gb
  redis_version           = var.redis_version
  authorized_network      = var.network_id
  connect_mode            = var.connect_mode
  reserved_ip_range       = var.reserved_ip_range
  auth_enabled            = true
  transit_encryption_mode = "SERVER_AUTHENTICATION"
  deletion_protection     = true
  labels                  = var.labels
  maintenance_policy {
    weekly_maintenance_window {
      day = var.maintenance_day
      start_time {
        hours   = var.maintenance_hour_utc
        minutes = 0
        seconds = 0
        nanos   = 0
      }

    }

  }
}
