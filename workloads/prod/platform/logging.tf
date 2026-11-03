module "logging" {
  source             = "../../../modules/logging"
  log_bucket_id      = var.log_bucket_id
  log_retention_days = var.log_retention_days
  log_sink_filter    = var.log_sink_filter
  log_sink_name      = var.log_sink_name
  project_id         = var.project_id
  region             = var.region
}
