output "https_ip" {
  value = module.https_load_balancer.ip
}
output "voice_ips" {
  value = module.external_addresses.addresses
}
