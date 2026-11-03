variable "cluster_name" {
  description = "Existing cluster managed by gke state."
  type        = string
}
variable "repositories" {
  description = "Docker/OCI repositories with explicit repository-level IAM members."
  type        = map(object({ description = string, readers = list(string), writers = list(string) }))
  default     = {}
}
variable "secret_names" {
  description = "Secret containers to create, without secret versions."
  type        = set(string)
  default     = []
}
variable "secret_accessors" {
  description = "Per-secret accessor bindings; keys must remain stable."
  type        = map(object({ secret_name = string, member = string }))
  default     = {}
}
variable "argocd_namespace" {
  description = "Namespace owned by this Terraform bootstrap."
  type        = string
}
variable "argocd_chart_version" {
  description = "Pinned Argo CD chart release."
  type        = string
}
variable "argocd_values_file" {
  description = "Relative path of reviewed Helm values within this layer."
  type        = string
}
variable "log_bucket_id" {
  description = "Custom workload log bucket ID."
  type        = string
}
variable "log_sink_name" {
  description = "Workload log sink name."
  type        = string
}
variable "log_retention_days" {
  description = "Retention to review against the agreed operations policy."
  type        = number
}
variable "log_sink_filter" {
  description = "Filter for the custom workload log sink."
  type        = string
}
variable "alert_email_addresses" {
  description = "Approved notification email recipients. Empty until real recipients are confirmed."
  type        = set(string)
  default     = []
}
variable "container_restart_threshold" {
  description = "Restarts within five minutes required to trigger an alert."
  type        = number
}
variable "build_triggers" {
  description = "Optional triggers referencing already-connected Cloud Build repositories."
  type = map(object({
    repository_resource      = string
    service_account_resource = string
    config_file              = string
    branch_regex             = string
    substitutions            = optional(map(string), {})
  }))
  default = {}
}

variable "workload_project_grants" {
  description = "Explicit additive project grants for approved workload principals. Prefer per-resource grants for secrets and registries."
  type        = map(object({ role = string, member = string }))
  default     = {}
}

variable "workload_identity_links" {
  description = "Optional KSA-to-existing-GSA impersonation links. GitOps must set the matching iam.gke.io/gcp-service-account annotation."
  type        = map(object({ service_account_id = string, namespace = string, kubernetes_service_account = string }))
  default     = {}
}

variable "kms_keyring_name" {
  description = "Optional CMEK key ring name. Wire service-agent permissions and resource encryption only after agreeing key ownership."
  type        = string
  default     = "vobiz-prod-keyring"
}

variable "kms_key_names" {
  description = "Optional symmetric keys. Empty until a CMEK requirement is confirmed."
  type        = list(string)
  default     = []
}
