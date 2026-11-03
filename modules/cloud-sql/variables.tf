variable "enable_sql" {
  description = "False while databases remain on AWS."
  type        = bool
  default     = false
}

variable "labels" {
  description = "Common resource labels."
  type        = map(string)
  default     = {}
}

variable "private_network_self_link" {
  description = "Existing VPC self-link with a network-owned PSA connection."
  type        = string
  default     = null
}

variable "private_services_range_name" {
  description = "Existing PSA range owned and connected by network state. Apply network first."
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

variable "sql" {
  description = "Mock PostgreSQL configuration; requires source compatibility, sizing and IAM user setup before use."
  type = object({
    name              = string
    database_version  = string
    tier              = string
    replica_tier      = string
    replica_zone      = string
    disk_size_gb      = number
    backup_start_time = string
    retained_backups  = number
  })
}
