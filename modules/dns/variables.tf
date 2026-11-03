variable "dns_zones" {
  description = "Explicit public zones and records. Does not change registrar delegation or existing AWS DNS."
  type = map(object({
    domain      = string
    description = string
    records     = list(object({ name = string, type = string, ttl = number, records = list(string) }))
  }))
  default = {}
}

variable "project_id" {
  description = "Target GCP project ID; replace the mock PROJECT ID before planning."
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Replace PROJECT ID with a valid GCP project ID."
  }
}
