output "repository_ids" {
  value = { for name, repo in google_artifact_registry_repository.repository : name => repo.id }
}
output "docker_urls" {
  value = { for name, repo in google_artifact_registry_repository.repository : name => "${repo.location}-docker.pkg.dev/${var.project_id}/${repo.repository_id}" }
}
