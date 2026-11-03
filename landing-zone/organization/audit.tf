# Authoritative for the listed service's audit configuration. Reconcile any
# existing exemption rules before applying; this does not alter IAM bindings.
resource "google_project_iam_audit_config" "data_access" {
  for_each = var.audit_services
  project  = local.target_project_id
  service  = each.value

  audit_log_config {
    log_type = "DATA_READ"
  }
  audit_log_config {
    log_type = "DATA_WRITE"
  }
}
