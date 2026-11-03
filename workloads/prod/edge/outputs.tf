output "https_ip" {
  description = "Optional HTTPS address, or null."
  value       = try(google_compute_global_address.https[0].address, null)
}
output "voice_ips" {
  description = "Optional reserved voice endpoint addresses."
  value       = { for name, address in google_compute_address.voice : name => address.address }
}
