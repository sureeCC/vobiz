mock_provider "google" {}
run "module_contract" {
  command = plan
  module {
    source = "../../../modules/workload-identity"
  }
  variables {
    project_id               = "test-project"
    workload_pool_project_id = "cluster-project"
    accounts                 = { app-runtime = { namespace = "app", kubernetes_service_account = "backend" } }
  }
  assert {
    condition     = google_service_account_iam_member.workload_identity["app-runtime"].member == "serviceAccount:cluster-project.svc.id.goog[app/backend]" && length(google_project_iam_member.role) == 0
    error_message = "The module must preserve its access, security and lifecycle contract."
  }
}
