resource "google_monitoring_notification_channel" "email" {
  for_each     = var.alert_email_addresses
  project      = var.project_id
  display_name = "Vobiz infrastructure: ${each.value}"
  type         = "email"
  labels       = { email_address = each.value }
}

resource "google_monitoring_alert_policy" "container_restarts" {
  project               = var.project_id
  display_name          = "Vobiz GKE excessive container restarts"
  combiner              = "OR"
  enabled               = true
  notification_channels = [for channel in google_monitoring_notification_channel.email : channel.name]
  conditions {
    display_name = "Container restart count increased"
    condition_threshold {
      filter          = "resource.type = \"k8s_container\" AND resource.labels.cluster_name = \"${var.cluster_name}\" AND metric.type = \"kubernetes.io/container/restart_count\""
      comparison      = "COMPARISON_GT"
      threshold_value = var.container_restart_threshold
      duration        = "0s"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_DELTA"
      }
      trigger { count = 1 }
    }
  }
  documentation {
    content   = "Inspect events, rollout changes, probes and container logs. Validate call-drain behavior before restarting voice workloads."
    mime_type = "text/markdown"
  }
}
