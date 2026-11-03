variable "alert_email_addresses" {
  description = "Approved notification email recipients. Empty until real recipients are confirmed."
  type        = set(string)
  default     = []
}

variable "cluster_name" {
  description = "Existing cluster managed by gke state."
  type        = string
}

variable "container_restart_threshold" {
  description = "Restarts within five minutes required to trigger an alert."
  type        = number
}

variable "project_id" {
  description = "Target GCP project ID; replace the mock PROJECT ID before planning."
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Replace PROJECT ID with a valid GCP project ID."
  }
}
