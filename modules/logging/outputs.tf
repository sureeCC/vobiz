output "bucket_id" {
  value = google_logging_project_bucket_config.workloads.bucket_id
}
output "sink_name" {
  value = google_logging_project_sink.workloads.name
}
