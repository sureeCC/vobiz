variable "kms_key_names" {
  description = "Optional symmetric keys. Empty until a CMEK requirement is confirmed."
  type        = list(string)
  default     = []
}

variable "kms_keyring_name" {
  description = "Optional CMEK key ring name. Wire service-agent permissions and resource encryption only after agreeing key ownership."
  type        = string
  default     = "vobiz-prod-keyring"
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
