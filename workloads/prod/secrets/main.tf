resource "google_secret_manager_secret" "secret" {
  for_each            = var.secrets
  project             = var.project_id
  secret_id           = coalesce(each.value.secret_id, each.key)
  labels              = var.labels
  deletion_protection = true
  replication {
    dynamic "auto" {
      for_each = length(each.value.replication_locations) == 0 ? [1] : []
      content {}
    }
    dynamic "user_managed" {
      for_each = length(each.value.replication_locations) == 0 ? [] : [each.value.replication_locations]
      content {
        dynamic "replicas" {
          for_each = user_managed.value
          content { location = replicas.value }
        }
      }
    }
  }
}
locals {
  grants = flatten([for name, secret in var.secrets : [
    for member in secret.accessors : { secret = name, member = member }
  ]])
}
resource "google_secret_manager_secret_iam_member" "accessor" {
  for_each  = { for grant in local.grants : jsonencode([grant.secret, grant.member]) => grant }
  project   = var.project_id
  secret_id = google_secret_manager_secret.secret[each.value.secret].secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = each.value.member
}
