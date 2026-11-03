output "instance_links" {
  description = "VM self-links by approved workload name."
  value       = { for name, instance in module.instances : name => instance.instances_self_links }
}
output "public_addresses" {
  description = "Reserved VM ingress IPs for carrier allowlisting."
  value       = { for name, address in google_compute_address.voice : name => address.address }
}
