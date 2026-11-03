output "notification_channels" {
  value = { for name, channel in google_monitoring_notification_channel.email : name => channel.name }
}
output "alert_policy_name" {
  value = google_monitoring_alert_policy.container_restarts.name
}
