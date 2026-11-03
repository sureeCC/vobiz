module "ha_vpn" {
  source                = "../../../modules/ha-vpn"
  advertised_ranges     = var.advertised_ranges
  aws_router_asn        = var.aws_router_asn
  enable_aws_vpn        = var.enable_aws_vpn
  gcp_router_asn        = var.gcp_router_asn
  labels                = var.labels
  network_name          = var.network_name
  peer_gateway_name     = var.peer_gateway_name
  peer_interfaces       = var.peer_interfaces
  peer_redundancy_type  = var.peer_redundancy_type
  project_id            = var.project_id
  region                = var.region
  tunnel_shared_secrets = var.tunnel_shared_secrets
  tunnels               = var.tunnels
  vpn_name              = var.vpn_name
}
