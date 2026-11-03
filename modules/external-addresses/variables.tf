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

variable "voice_address_names" {
  description = "Reserve standalone voice IPs only after the endpoint design is approved. VM-owned addresses belong to voice state instead."
  type        = set(string)
  default     = []
}
