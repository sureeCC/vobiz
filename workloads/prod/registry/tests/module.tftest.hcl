mock_provider "google" {}
run "module_contract" {
  command = plan
  module {
    source = "../../../modules/artifact-registry"
  }
  variables {
    project_id   = "test-project"
    region       = "asia-south1"
    repositories = { app = { readers = ["serviceAccount:node@test-project.iam.gserviceaccount.com"], writers = ["serviceAccount:build@test-project.iam.gserviceaccount.com"] } }
  }
  assert {
    condition     = google_artifact_registry_repository.repository["app"].docker_config[0].immutable_tags && length(google_artifact_registry_repository_iam_member.access) == 2
    error_message = "The module must preserve its access, security and lifecycle contract."
  }
}
