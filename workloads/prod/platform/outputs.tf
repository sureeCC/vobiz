output "repositories" {
  description = "Created repository resource IDs."
  value       = { for name, repository in module.repositories : name => repository.artifact_id }
}
output "secret_names" {
  description = "Secret container names; no credential values are exported."
  value       = module.secrets.secret_names
}
output "argocd_namespace" {
  description = "Argo CD bootstrap namespace."
  value       = kubernetes_namespace_v1.argocd.metadata[0].name
}
