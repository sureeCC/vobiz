output "instance_links" {
  value = { for name, instance in module.instances : name => instance.instances_self_links }
}
output "public_addresses" {
  value = { for name, address in google_compute_address.voice : name => address.address }
}
output "instance_count" {
  value = length(module.instances)
}
