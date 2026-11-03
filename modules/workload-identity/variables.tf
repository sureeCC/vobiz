variable "project_id" {
  description = "Target GCP project ID; replace the mock PROJECT ID before planning."
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Replace PROJECT ID with a valid GCP project ID."
  }
}

variable "workload_identity_links" {
  description = "Optional KSA-to-existing-GSA impersonation links. GitOps must set the matching iam.gke.io/gcp-service-account annotation."
  type        = map(object({ service_account_id = string, namespace = string, kubernetes_service_account = string }))
  default     = {}
}

variable "workload_project_grants" {
  description = "Explicit additive project grants for approved workload principals. Prefer per-resource grants for secrets and registries."
  type        = map(object({ role = string, member = string }))
  default     = {}
}
