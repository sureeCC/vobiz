variable "project_id" {
  type        = string
  description = "Existing GCP project ID; placeholder values are rejected."
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Use an existing GCP project ID: 6-30 lowercase letters, digits or hyphens."
  }
}
variable "region" {
  type    = string
  default = "asia-south1"
}

variable "secrets" {
  type = map(object({
    accessors             = optional(set(string), [])
    replication_locations = optional(set(string), [])

  }))
  description = "Secret IDs and resource-scoped accessor members. Empty locations selects automatic replication. No secret payloads are accepted."
}
