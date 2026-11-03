output "addresses" {
  value = { for name, address in google_compute_address.voice : name => address.address }
}
output "address_count" {
  value = length(google_compute_address.voice)
}
