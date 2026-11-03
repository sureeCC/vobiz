output "vpn_gateway" {
  description = "GCP HA VPN gateway details, or null when disabled."
  value       = try(module.aws_vpn[0].gateway, null)
}
output "vpn_tunnel_names" {
  description = "Created tunnel names, or an empty list."
  value       = try(module.aws_vpn[0].tunnel_names, [])
}
