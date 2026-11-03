variable "log_bucket_id" {
  description = "Custom workload log bucket ID."
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

variable "log_sink_name" {
  description = "Workload log sink name."
  type        = string
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
