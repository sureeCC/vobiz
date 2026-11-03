variable "instances" {
  description = "Approved individual VM inventory. Empty while exact SIP/VM membership remains unresolved. No autohealing/replacement of active calls is configured."
  type = map(object({
    zone             = string
    machine_type     = string
    source_image     = string
    disk_size_gb     = number
    assign_public_ip = optional(bool, false)
    network_tags     = optional(list(string), ["iap-ssh"])
  }))
  default = {}
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

variable "service_account_name" {
  description = "Dedicated least-privilege VM service account ID."
  type        = string
}

variable "subnetwork_name" {
  description = "Approved existing subnet for SIP/carrier VMs."
  type        = string
}
