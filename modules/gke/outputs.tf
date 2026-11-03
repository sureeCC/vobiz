output "cluster_name" {
  description = "Cluster name used by platform configuration."
  value       = module.gke.name
}
output "cluster_location" {
  description = "Regional cluster location."
  value       = module.gke.location
}
output "node_service_account_email" {
  description = "Node identity for repository-scoped image pull grants."
  value       = module.node_identity.email
}
output "workload_identity_pool" {
  description = "Workload Identity Federation pool name."
  value       = "${var.project_id}.svc.id.goog"
}
