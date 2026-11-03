variable "labels" {
  description = "Common resource labels."
  type        = map(string)
  default     = {}
}

variable "project_id" {
  description = "Target GCP project ID; replace the mock PROJECT ID before planning."
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Replace PROJECT ID with a valid GCP project ID."
  }
}

variable "secret_accessors" {
  description = "Per-secret accessor bindings; keys must remain stable."
  type        = map(object({ secret_name = string, member = string }))
  default     = {}
}

variable "secret_names" {
  description = "Secret containers to create, without secret versions."
  type        = set(string)
  default     = []
}
