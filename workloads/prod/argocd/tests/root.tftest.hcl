mock_provider "google" {
  mock_data "google_container_cluster" {
    defaults = { endpoint = "127.0.0.1", master_auth = [{ cluster_ca_certificate = "bW9jay1jYQ==" }] }
  }
}
mock_provider "helm" {}
variables {
  project_id       = "test-project"
  region           = "asia-south1"
  cluster_name     = "test-cluster"
  cluster_location = "asia-south1"
  namespace        = "gitops"
  values           = ["server:\n  replicas: 2\n"]
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

run "invalid_values" {
  command = plan
  variables { values = ["bad: ["] }
  expect_failures = [var.values]
}

run "scalar_values" {
  command = plan
  variables { values = ["a scalar"] }
  expect_failures = [var.values]
}
