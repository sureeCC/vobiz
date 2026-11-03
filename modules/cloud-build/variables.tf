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

variable "project_id" {
  description = "Target GCP project ID; replace the mock PROJECT ID before planning."
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Replace PROJECT ID with a valid GCP project ID."
  }
}

variable "region" {
  description = "GCP deployment region."
  type        = string
}
