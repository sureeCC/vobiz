module "monitoring" {
  source                      = "../../../modules/monitoring"
  alert_email_addresses       = var.alert_email_addresses
  cluster_name                = var.cluster_name
  container_restart_threshold = var.container_restart_threshold
  project_id                  = var.project_id
}
