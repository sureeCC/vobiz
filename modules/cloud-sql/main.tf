# Subsequent data migration only. Provisioning this does NOT migrate AWS data.
module "postgresql" {
  count   = var.enable_sql ? 1 : 0
  source  = "GoogleCloudPlatform/sql-db/google//modules/postgresql"
  version = "28.3.0"

  project_id                  = var.project_id
  name                        = var.sql.name
  region                      = var.region
  database_version            = var.sql.database_version
  tier                        = var.sql.tier
  availability_type           = "REGIONAL"
  disk_size                   = var.sql.disk_size_gb
  disk_autoresize             = true
  deletion_protection         = true
  deletion_protection_enabled = true
  enable_default_user         = false
  enable_default_db           = false
  database_flags              = [{ name = "cloudsql.iam_authentication", value = "on" }]
  ip_configuration = {
    ipv4_enabled       = false
    private_network    = var.private_network_self_link
    allocated_ip_range = var.private_services_range_name
    ssl_mode           = "ENCRYPTED_ONLY"
  }
  backup_configuration = {
    enabled                        = true
    start_time                     = var.sql.backup_start_time
    point_in_time_recovery_enabled = true
    transaction_log_retention_days = "7"
    retained_backups               = var.sql.retained_backups
    retention_unit                 = "COUNT"
  }
  read_replicas = [{
    name              = "read-01"
    tier              = var.sql.replica_tier
    availability_type = "ZONAL"
    zone              = var.sql.replica_zone
    disk_size         = tostring(var.sql.disk_size_gb)
    disk_autoresize   = true
    user_labels       = var.labels
    ip_configuration = {
      ipv4_enabled       = false
      private_network    = var.private_network_self_link
      allocated_ip_range = var.private_services_range_name
      ssl_mode           = "ENCRYPTED_ONLY"
    }
  }]

}
