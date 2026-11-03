module "repositories" {
  for_each = var.repositories
  source   = "GoogleCloudPlatform/artifact-registry/google"
  version  = "0.8.2"

  project_id    = var.project_id
  location      = var.region
  repository_id = each.key
  format        = "DOCKER"
  description   = each.value.description
  labels        = var.labels
  docker_config = { immutable_tags = true }
  members = {
    readers = each.value.readers
    writers = each.value.writers
  }
}
