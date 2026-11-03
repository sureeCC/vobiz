moved {
  from = module.repositories
  to   = module.artifact_registry.module.repositories
}
moved {
  from = module.secrets
  to   = module.secret_manager.module.secrets
}
moved {
  from = google_secret_manager_secret_iam_member.accessors
  to   = module.secret_manager.google_secret_manager_secret_iam_member.accessors
}
moved {
  from = google_project_iam_member.workloads
  to   = module.workload_identity.google_project_iam_member.workloads
}
moved {
  from = google_service_account_iam_member.workloads
  to   = module.workload_identity.google_service_account_iam_member.workloads
}
moved {
  from = google_monitoring_notification_channel.email
  to   = module.monitoring.google_monitoring_notification_channel.email
}
moved {
  from = google_monitoring_alert_policy.container_restarts
  to   = module.monitoring.google_monitoring_alert_policy.container_restarts
}
moved {
  from = google_logging_project_bucket_config.workloads
  to   = module.logging.google_logging_project_bucket_config.workloads
}
moved {
  from = google_logging_project_sink.workloads
  to   = module.logging.google_logging_project_sink.workloads
}
moved {
  from = google_project_iam_member.log_sink_writer
  to   = module.logging.google_project_iam_member.log_sink_writer
}
moved {
  from = google_cloudbuild_trigger.images
  to   = module.cloud_build.google_cloudbuild_trigger.images
}
moved {
  from = module.kms
  to   = module.encryption_keys.module.kms
}
moved {
  from = kubernetes_namespace_v1.argocd
  to   = module.argocd.kubernetes_namespace_v1.argocd
}
moved {
  from = helm_release.argocd
  to   = module.argocd.helm_release.argocd
}
