variable "project_id" {
  type        = string
  description = "ID of the Project."
}

variable "region" {
  default     = "asia-south1"
  type        = string
  description = "The region to deploy the resource."
}

variable "name" {
  type        = string
  description = "Name of the router"
}

variable "create_router" {
  type        = bool
  default     = false
  description = "Create router instead of using an existing one, uses 'router' variable for new resource name."
}

variable "subnetworks" {
  type = list(object({
    name                     = string,
    source_ip_ranges_to_nat  = list(string)
    secondary_ip_range_names = list(string)
  }))
  description = "Specifies one or more subnetwork NAT configurations"
  default     = []
}

variable "description" {
  type        = string
  description = "An optional description of this resource"
  default     = ""
}

variable "nats" {
  type = list(object({
    name                                = string
    nat_ip_allocate_option              = optional(string)
    source_subnetwork_ip_ranges_to_nat  = optional(string)
    nat_ips                             = optional(list(string), [])
    drain_nat_ips                       = optional(list(string), [])
    min_ports_per_vm                    = optional(number)
    max_ports_per_vm                    = optional(number)
    udp_idle_timeout_sec                = optional(number)
    icmp_idle_timeout_sec               = optional(number)
    tcp_established_idle_timeout_sec    = optional(number)
    tcp_transitory_idle_timeout_sec     = optional(number)
    tcp_time_wait_timeout_sec           = optional(number)
    enable_endpoint_independent_mapping = optional(bool)
    enable_dynamic_port_allocation      = optional(bool)

    log_config = optional(object({
      enable = optional(bool, true)
      filter = optional(string, "ALL")
    }), {})

    subnetworks = optional(list(object({
      name                     = string
      source_ip_ranges_to_nat  = list(string)
      secondary_ip_range_names = optional(list(string))
    })), [])

  }))
  default     = []
  description = "NATs to deploy on this router."
}

variable "network" {
  type        = string
  description = "A reference to the network to which this router belongs"
}
