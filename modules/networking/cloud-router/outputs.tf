output "router" {
  value = module.cloud_router.router
}

output "nat" {
  description = "The created Cloud NAT resources, if available."
  value       = try(length(module.cloud_router.nat) > 0 ? module.cloud_router.nat : null, null)
}
