variable "project_id" {
  description = "Existing administrative project that owns the Terraform state bucket."
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Replace PROJECT ID with a valid existing GCP project ID."
  }
}

variable "region" {
  description = "Region for the state bucket."
  type        = string
}

variable "state_admin_members" {
  description = "Explicit user/group/serviceAccount principals allowed to manage state objects."
  type        = set(string)
  default     = []
}

variable "state_bucket_name" {
  description = "Globally unique name of the Terraform state bucket."
  type        = string
}
