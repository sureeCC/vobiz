mock_provider "google" {}
variables {
  project_id               = "test-project"
  region                   = "asia-south1"
  workload_pool_project_id = "cluster-project"
  accounts                 = { app-runtime = { namespace = "app", kubernetes_service_account = "backend", project_roles = ["roles/logging.logWriter"] } }
}
run "root_contract" {
  command = plan
  assert {
    condition     = alltrue([for api in google_project_service.required : api.project == var.project_id && api.disable_on_destroy == false])
    error_message = "Root API configuration must preserve the requested project and shared APIs."
  }
}
run "invalid_project" {
  command = plan
  variables { project_id = "REPLACE_PROJECT" }
  expect_failures = [var.project_id]
}

run "empty_inventory" {
  command = plan
  variables { accounts = {} }
  assert {
    condition     = length(output.service_account_emails) == 0
    error_message = "An empty inventory must produce no resources in its output map."
  }
}
