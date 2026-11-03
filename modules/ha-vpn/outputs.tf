output "gateway" {
  value = try(module.aws_vpn[0].gateway, null)
}
output "tunnel_names" {
  value = try(module.aws_vpn[0].tunnel_names, [])
}
output "gateway_count" {
  value = length(module.aws_vpn)
}
