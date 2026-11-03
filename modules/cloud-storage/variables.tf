variable "buckets" {
  description = "Explicitly approved application bucket names and storage settings. Empty initially."
  type        = map(object({ storage_class = string, versioning = bool }))
  default     = {}
}

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
