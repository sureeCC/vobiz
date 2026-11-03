module "voice_identity" {
  count        = length(var.instances) > 0 ? 1 : 0
  source       = "terraform-google-modules/service-accounts/google"
  version      = "5.1.0"
  project_id   = var.project_id
  names        = [var.service_account_name]
  display_name = "Vobiz voice VM identity"
  project_roles = [
    "${var.project_id}=>roles/logging.logWriter",
    "${var.project_id}=>roles/monitoring.metricWriter"
  ]
  generate_keys = false
}
