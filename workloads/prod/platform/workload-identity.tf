# GitOps owns Kubernetes service accounts. Terraform owns only these IAM grants.
# Use principal://... members for direct WIF access; no service-account keys.
variable "workload_project_grants" {
  description = "Explicit additive project grants for approved workload principals. Prefer per-resource grants for secrets and registries."
  type        = map(object({ role = string, member = string }))
  default     = {}
}

resource "google_project_iam_member" "workloads" {
  for_each = var.workload_project_grants
  project  = var.project_id
  role     = each.value.role
  member   = each.value.member
}

variable "workload_identity_links" {
  description = "Optional KSA-to-existing-GSA impersonation links. GitOps must set the matching iam.gke.io/gcp-service-account annotation."
  type        = map(object({ service_account_id = string, namespace = string, kubernetes_service_account = string }))
  default     = {}
}

resource "google_service_account_iam_member" "workloads" {
  for_each           = var.workload_identity_links
  service_account_id = each.value.service_account_id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${each.value.namespace}/${each.value.kubernetes_service_account}]"
}
