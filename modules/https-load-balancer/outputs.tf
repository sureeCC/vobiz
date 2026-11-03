output "ip" {
  value = try(google_compute_global_address.https[0].address, null)
}
output "instance_count" {
  value = length(module.https)
}
