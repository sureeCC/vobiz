# Optional Phase 2 root. No AWS provider or AWS mutations are included.
data "google_compute_network" "production" {
  count   = var.enable_aws_vpn ? 1 : 0
  project = var.project_id
  name    = var.network_name
}

module "aws_vpn" {
  count   = var.enable_aws_vpn ? 1 : 0
  source  = "terraform-google-modules/vpn/google//modules/vpn_ha"
  version = "7.1.0"

  project_id = var.project_id
  region     = var.region
  name       = var.vpn_name
  network    = data.google_compute_network.production[0].self_link
  router_asn = var.gcp_router_asn
  labels     = var.labels
  # This module creates its own dedicated VPN router, separate from NAT.
  peer_external_gateway = {
    name            = var.peer_gateway_name
    redundancy_type = var.peer_redundancy_type
    interfaces      = var.peer_interfaces
  }
  router_advertise_config = {
    mode      = "CUSTOM"
    groups    = []
    ip_ranges = var.advertised_ranges
  }
  tunnels = { for name, tunnel in var.tunnels : name => {
    bgp_peer                        = { address = tunnel.peer_bgp_address, asn = var.aws_router_asn }
    bgp_session_range               = tunnel.gcp_bgp_cidr
    vpn_gateway_interface           = tunnel.gcp_interface
    peer_external_gateway_interface = tunnel.peer_interface
    ike_version                     = 2
    shared_secret                   = var.tunnel_shared_secrets[name]
  } }
}
