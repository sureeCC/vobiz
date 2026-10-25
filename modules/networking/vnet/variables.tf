variable "project_id" {
  type        = string
  description = "ID of the Project."
}

variable "network_name" {
  type = string
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
  default     = {}
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
  default     = []
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
  default     = []
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
  default     = []
}

variable "private_service_access_config" {
  type = object({
    enable_private_services_connection = bool
    address_name                       = string
    prefix_length                      = number
  })
  description = "Configuration for Private Service Access (PSA) connection."
  default = {
    "address_name" : "private-ip-address",
    "enable_private_services_connection" : false,
    "prefix_length" : 16
  }
}

variable "delete_default_internet_gateway_routes" {
  type        = bool
  description = "If set, ensure that all routes within the network specified whose names begin with 'default-route' and with a next hop of 'default-internet-gateway' are deleted"
  default     = false
}

variable "description" {
  type        = string
  description = "An optional description of this resource. The resource must be recreated to modify this field."
  default     = ""
}
