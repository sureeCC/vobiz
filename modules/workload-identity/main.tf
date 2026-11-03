# GitOps owns Kubernetes service accounts. Terraform owns only these IAM grants.
# Use principal://... members for direct WIF access; no service-account keys.
resource "google_project_iam_member" "workloads" {
  for_each = var.workload_project_grants
  project  = var.project_id
  role     = each.value.role
  member   = each.value.member
}

resource "google_service_account_iam_member" "workloads" {
  for_each           = var.workload_identity_links
  service_account_id = each.value.service_account_id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${each.value.namespace}/${each.value.kubernetes_service_account}]"
}
