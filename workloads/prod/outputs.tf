output "network_name" {
  value       = module.networking.network_name
  description = "The name of the VPC being created"
}

output "network_id" {
  value       = module.networking.network_id
  description = "The ID of the VPC being created"
}

output "route_names" {
  value       = module.networking.route_names
  description = "The route names associated with this VPC"
}

output "subnets" {
  value       = module.networking.subnets
  description = "A map with keys of form subnet_region/subnet_name and values being the outputs of the google_compute_subnetwork resources used to create corresponding subnets."
}

output "subnets_ids" {
  value       = module.networking.subnets_ids
  description = "The IDs of the subnets being created"
}

output "subnets_names" {
  value       = module.networking.subnets_names
  description = "The names of the subnets being created"
}

output "subnets_secondary_ranges" {
  value       = module.networking.subnets_secondary_ranges
  description = "The secondary ranges associated with these subnets"
}
