mock_provider "google" {}
variables {
  project_id           = "test-project"
  region               = "asia-south1"
  name                 = "test-cache"
  network_id           = "projects/test-project/global/networks/test-vpc"
  memory_size_gb       = 7
  maintenance_day      = "TUESDAY"
  maintenance_hour_utc = 3
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

run "invalid_memory_size_gb" {
  command = plan
  variables { memory_size_gb = 0 }
  expect_failures = [var.memory_size_gb]
}

run "invalid_maintenance_hour_utc" {
  command = plan
  variables { maintenance_hour_utc = 24 }
  expect_failures = [var.maintenance_hour_utc]
}
