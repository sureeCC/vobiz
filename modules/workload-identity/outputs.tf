output "service_account_emails" {
  value = { for name, account in google_service_account.workload : name => account.email
  }
}
output "kubernetes_annotations" {
  value = { for name, account in google_service_account.workload : name => { "iam.gke.io/gcp-service-account" = account.email
    }
  }
}
