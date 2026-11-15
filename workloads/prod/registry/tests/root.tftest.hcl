mock_provider "google" {}
variables {
  project_id   = "test-project"
  region       = "asia-south1"
  repositories = { app = { readers = ["serviceAccount:node@test-project.iam.gserviceaccount.com"], writers = ["serviceAccount:build@test-project.iam.gserviceaccount.com"] } }
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
  variables { repositories = {} }
  assert {
    condition     = length(output.docker_urls) == 0
    error_message = "An empty inventory must produce no resources in its output map."
  }
}
