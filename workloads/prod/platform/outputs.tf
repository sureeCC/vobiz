output "repositories" {
  value = module.artifact_registry.repositories
}
output "secret_names" {
  value = module.secret_manager.secret_names
}
output "argocd_namespace" {
  value = module.argocd.namespace
}
