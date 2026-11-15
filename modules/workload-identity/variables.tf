variable "project_id" {
  type        = string
  description = "Existing GCP project ID; placeholder values are rejected."
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Use an existing GCP project ID: 6-30 lowercase letters, digits or hyphens."
  }
}
variable "workload_pool_project_id" {
  type        = string
  description = "Project hosting the GKE workload pool; may differ from the Google service-account project."
}
variable "accounts" {
  type = map(object({
    namespace                  = string
    kubernetes_service_account = string
    display_name               = optional(string, "GKE workload identity")
    project_roles              = optional(set(string), [])

  }))
  description = "Google service-account IDs mapped to existing Kubernetes namespace/service-account identities."
}
