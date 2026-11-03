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

variable "region" {
  description = "GCP deployment region."
  type        = string
}

variable "repositories" {
  description = "Docker/OCI repositories with explicit repository-level IAM members."
  type        = map(object({ description = string, readers = list(string), writers = list(string) }))
  default     = {}
}
