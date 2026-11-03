variable "advertised_ranges" {
  description = "Explicit GCP CIDR => description advertisements. Include Pod CIDRs only when the selected masquerade design requires it."
  type        = map(string)
  default     = {}
}

variable "aws_router_asn" {
  description = "Peer AWS VGW/TGW ASN."
  type        = number
}

variable "enable_aws_vpn" {
  description = "Explicitly enable only after AWS gateway, tunnel and route design is agreed."
  type        = bool
  default     = false
}

variable "gcp_router_asn" {
  description = "GCP Cloud Router ASN."
  type        = number
}

variable "labels" {
  description = "Common resource labels."
  type        = map(string)
  default     = {}
}

variable "network_name" {
  description = "Existing network name."
  type        = string
}

variable "peer_gateway_name" {
  description = "External AWS gateway representation name."
  type        = string
}

variable "peer_interfaces" {
  description = "AWS-provided public tunnel endpoints; documentation IPs are mocks only."
  type        = list(object({ id = number, ip_address = string }))
  default     = []
}

variable "peer_redundancy_type" {
  description = "Must match AWS's actual endpoint topology."
  type        = string
  default     = "FOUR_IPS_REDUNDANCY"
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

variable "tunnel_shared_secrets" {
  description = "Provide through a secure TF_VAR_tunnel_shared_secrets environment variable. Values are sensitive but will exist in VPN state."
  type        = map(string)
  sensitive   = true
  default     = {}
  validation {
    condition = !var.enable_aws_vpn || alltrue([
      for name in keys(var.tunnels) : length(lookup(var.tunnel_shared_secrets, name, "")) >= 16
    ])
    error_message = "Supply a real shared secret of at least 16 characters for every enabled tunnel."
  }
}

variable "tunnels" {
  description = "Tunnel topology and BGP /30 addresses obtained from AWS configuration."
  type = map(object({
    peer_bgp_address = string
    gcp_bgp_cidr     = string
    gcp_interface    = number
    peer_interface   = number
  }))
  default = {}
}

variable "vpn_name" {
  description = "GCP HA VPN name."
  type        = string
}
