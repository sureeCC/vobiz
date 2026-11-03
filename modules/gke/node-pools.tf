# Counts below are TOTAL across the listed zones, not per-zone min/max values.
# Media/signaling pools should be added only after workload and call-drain review.
locals {
  node_pools = [for pool in var.node_pools : {
    name               = pool.name
    machine_type       = pool.machine_type
    node_locations     = join(",", var.zones)
    autoscaling        = pool.autoscaling
    total_min_count    = pool.total_min_count
    total_max_count    = pool.total_max_count
    initial_node_count = pool.initial_nodes_per_zone
    disk_size_gb       = pool.disk_size_gb
    disk_type          = "pd-balanced"
    image_type         = "COS_CONTAINERD"
    auto_repair        = pool.auto_repair
    auto_upgrade       = pool.auto_upgrade
    max_surge          = pool.max_surge
    max_unavailable    = pool.max_unavailable
    spot               = false
  }]
  node_pool_labels = { for pool in var.node_pools : pool.name => pool.labels }
  node_pool_taints = { for pool in var.node_pools : pool.name => pool.taints }
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
