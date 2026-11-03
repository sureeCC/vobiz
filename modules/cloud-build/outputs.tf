output "trigger_ids" {
  value = { for name, trigger in google_cloudbuild_trigger.images : name => trigger.id }
}
