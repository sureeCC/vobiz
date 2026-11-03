# No trigger exists until an existing source connection/repository is supplied.
resource "google_cloudbuild_trigger" "images" {
  for_each        = var.build_triggers
  project         = var.project_id
  location        = var.region
  name            = each.key
  service_account = each.value.service_account_resource
  filename        = each.value.config_file
  repository_event_config {
    repository = each.value.repository_resource
    push { branch = each.value.branch_regex }
  }
  substitutions = each.value.substitutions
}
