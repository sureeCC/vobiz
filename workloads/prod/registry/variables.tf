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

variable "repositories" {
  type = map(object({
    description    = optional(string, "Managed Docker repository")
    readers        = optional(set(string), [])
    writers        = optional(set(string), [])
    immutable_tags = optional(bool, true)

  }))
  description = "Repository IDs with IAM members such as serviceAccount:email; readers should include the GKE node identity."
}
