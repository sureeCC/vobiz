### VNet ###
variable "network_name" {
  type        = string
  description = "Name of the VPC owned by the network layer."
}

variable "routing_mode" {
  type        = string
  default     = "REGIONAL"
  description = "The network-wide routing mode to use."
}

variable "subnets" {
  type = list(object({
    subnet_name                      = string
    subnet_ip                        = string
    subnet_region                    = optional(string)
    subnet_private_access            = optional(string)
    subnet_private_ipv6_access       = optional(string)
    subnet_flow_logs                 = optional(string)
    subnet_flow_logs_interval        = optional(string)
    subnet_flow_logs_sampling        = optional(string)
    subnet_flow_logs_metadata        = optional(string)
    subnet_flow_logs_filter          = optional(string)
    subnet_flow_logs_metadata_fields = optional(list(string))
    description                      = optional(string)
    purpose                          = optional(string)
    role                             = optional(string)
    stack_type                       = optional(string)
    ipv6_access_type                 = optional(string)
    ip_collection                    = optional(string)
    external_ipv6_prefix             = optional(string)
  }))
  description = "The list of subnets being created"
}

variable "secondary_ranges" {
  type = map(list(object({
    range_name = string, ip_cidr_range = optional(string), reserved_internal_range = optional(string)
  })))
  description = "Secondary ranges that will be used in some of the subnets"
}

variable "routes" {
  type = list(object({
    name                   = string
    description            = optional(string)
    tags                   = optional(list(string), [])
    destination_range      = string
    next_hop_gateway       = optional(string)
    next_hop_internet      = optional(bool, false)
    next_hop_ip            = optional(string)
    next_hop_instance      = optional(string)
    next_hop_instance_zone = optional(string)
    next_hop_vpn_tunnel    = optional(string)
    next_hop_ilb           = optional(string)
    priority               = optional(number, 1000)
  }))
  description = "List of routes being created in this VPC."
}

variable "egress_rules" {
  type = list(object({
    name                    = string
    description             = optional(string, null)
    disabled                = optional(bool, null)
    priority                = optional(number, null)
    destination_ranges      = optional(list(string), [])
    source_ranges           = optional(list(string), [])
    source_tags             = optional(list(string))
    source_service_accounts = optional(list(string))
    target_tags             = optional(list(string))
    target_service_accounts = optional(list(string))

    allow = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })), [])
    deny = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })), [])
    log_config = optional(object({
      metadata = string
    }))
  }))
  description = "List of egress rules. This will be ignored if variable 'rules' is non-empty"
}

variable "ingress_rules" {
  type = list(object({
    name                    = string
    description             = optional(string, null)
    disabled                = optional(bool, null)
    priority                = optional(number, null)
    destination_ranges      = optional(list(string), [])
    source_ranges           = optional(list(string), [])
    source_tags             = optional(list(string))
    source_service_accounts = optional(list(string))
    target_tags             = optional(list(string))
    target_service_accounts = optional(list(string))

    allow = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })), [])
    deny = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })), [])
    log_config = optional(object({
      metadata = string
    }))
  }))
  description = "List of ingress rules. This will be ignored if variable 'rules' is non-empty"
}

variable "private_service_access_config" {
  type = object({
    enable_private_services_connection = bool
    address_name                       = string
    prefix_length                      = number
  })
  description = "Configuration for Private Service Access (PSA) connection."
}

variable "delete_default_internet_gateway_routes" {
  type        = bool
  description = "If set, ensure that all routes within the network specified whose names begin with 'default-route' and with a next hop of 'default-internet-gateway' are deleted"
}

variable "vnet_description" {
  type        = string
  description = "An optional description of this resource. The resource must be recreated to modify this field."
}

### Cloud Router ###

variable "router_name" {
  type        = string
  description = "Name of the router"
}

variable "create_router" {
  type        = bool
  default     = false
  description = "Create the egress router and its configured NATs; false leaves routing external."
}

variable "router_description" {
  type        = string
  description = "An optional description of this resource"
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
