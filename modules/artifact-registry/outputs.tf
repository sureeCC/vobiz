output "repositories" {
  value = { for name, repository in module.repositories : name => repository.artifact_id }
}
