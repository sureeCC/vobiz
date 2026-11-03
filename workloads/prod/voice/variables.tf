variable "subnetwork_name" {
  description = "Approved existing subnet for SIP/carrier VMs."
  type        = string
}
variable "service_account_name" {
  description = "Dedicated least-privilege VM service account ID."
  type        = string
}
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
