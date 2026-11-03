# User-defined log bucket. _Required and _Default remain under existing ownership.
resource "google_logging_project_bucket_config" "workloads" {
  project        = var.project_id
  location       = var.region
  bucket_id      = var.log_bucket_id
  retention_days = var.log_retention_days
}

resource "google_logging_project_sink" "workloads" {
  project                = var.project_id
  name                   = var.log_sink_name
  destination            = "logging.googleapis.com/projects/${var.project_id}/locations/${var.region}/buckets/${google_logging_project_bucket_config.workloads.bucket_id}"
  filter                 = var.log_sink_filter
  unique_writer_identity = true
}

resource "google_project_iam_member" "log_sink_writer" {
  project = var.project_id
  role    = "roles/logging.bucketWriter"
  member  = google_logging_project_sink.workloads.writer_identity
}
