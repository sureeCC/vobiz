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
variable "environment" {
  description = "Environment label."
  type        = string
}
variable "labels" {
  description = "Common resource labels."
  type        = map(string)
  default     = {}
}
variable "impersonate_service_account" {
  description = "Optional existing deployment identity; use ADC/WIF when null. Backend authentication is configured separately."
  type        = string
  default     = null
}
