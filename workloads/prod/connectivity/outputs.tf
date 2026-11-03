output "vpn_gateway" {
  value = module.ha_vpn.gateway
}
output "vpn_tunnel_names" {
  value = module.ha_vpn.tunnel_names
}
