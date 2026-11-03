variable "cluster_name" {
  description = "Regional GKE cluster name."
  type        = string
}
variable "network_name" {
  description = "Existing network from the network layer."
  type        = string
}
variable "subnetwork_name" {
  description = "Existing private node subnet."
  type        = string
}
variable "pod_range_name" {
  description = "Existing Pod secondary range name."
  type        = string
}
variable "service_range_name" {
  description = "Existing Service secondary range name."
  type        = string
}
variable "zones" {
  description = "GKE node zones in the deployment region."
  type        = list(string)
  validation {
    condition     = length(distinct(var.zones)) == 3
    error_message = "This Vobiz regional design requires three distinct zones."
  }
}
variable "node_service_account_name" {
  description = "Dedicated node service account ID."
  type        = string
}
variable "control_plane_cidr" {
  description = "Non-overlapping /28 control-plane CIDR."
  type        = string
  validation {
    condition     = can(cidrnetmask(var.control_plane_cidr)) && can(regex("/28$", var.control_plane_cidr))
    error_message = "Control plane must use a valid non-overlapping IPv4 /28 range."
  }
}
variable "enable_private_endpoint" {
  description = "True requires the platform deployment runner to reach the private control plane."
  type        = bool
  default     = true
}
variable "master_authorized_networks" {
  description = "Approved administration CIDRs. No unrestricted access is accepted."
  type        = list(object({ cidr_block = string, display_name = string }))
  default     = []
  validation {
    condition     = alltrue([for network in var.master_authorized_networks : network.cidr_block != "0.0.0.0/0"])
    error_message = "Use explicit trusted administration ranges instead of 0.0.0.0/0."
  }
}
variable "release_channel" {
  description = "GKE release channel; patch versions remain channel-managed."
  type        = string
  default     = "REGULAR"
}
variable "maintenance_start_time" {
  description = "Daily maintenance window start, UTC HH:MM."
  type        = string
  default     = "20:30"
}

variable "node_pools" {
  description = "Mock capacity until measured sizing is approved. Total autoscaling bounds span all zones."
  type = list(object({
    name                   = string
    machine_type           = string
    total_min_count        = number
    total_max_count        = number
    initial_nodes_per_zone = number
    disk_size_gb           = number
    autoscaling            = optional(bool, true)
    auto_repair            = optional(bool, true)
    auto_upgrade           = optional(bool, true)
    max_surge              = optional(number, 1)
    max_unavailable        = optional(number, 0)
    labels                 = optional(map(string), {})
    taints                 = optional(list(object({ key = string, value = string, effect = string })), [])
  }))
  validation {
    condition = length(var.node_pools) > 0 && alltrue([
      for pool in var.node_pools : pool.total_min_count >= 0 && pool.total_max_count >= pool.total_min_count
    ])
    error_message = "Define at least one node pool with valid total autoscaling bounds."
  }
}
