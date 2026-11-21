resource "google_artifact_registry_repository" "repository" {
  for_each      = var.repositories
  project       = var.project_id
  location      = var.region
  repository_id = coalesce(each.value.repository_id, each.key)
  description   = each.value.description
  format        = "DOCKER"
  labels        = var.labels
  docker_config {
    immutable_tags = each.value.immutable_tags
  }
}

locals {
  grants = flatten([for name, repo in var.repositories : concat(
    [for member in repo.readers : { repository = name, role = "roles/artifactregistry.reader", member = member }],
    [for member in repo.writers : { repository = name, role = "roles/artifactregistry.writer", member = member }]
  )])
}
resource "google_artifact_registry_repository_iam_member" "access" {
  for_each   = { for grant in local.grants : jsonencode([grant.repository, grant.role, grant.member]) => grant }
  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.repository[each.value.repository].name
  role       = each.value.role
  member     = each.value.member
}
