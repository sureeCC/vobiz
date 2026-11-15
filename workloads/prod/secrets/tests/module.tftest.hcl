mock_provider "google" {}
run "module_contract" {
  command = plan
  module {
    source = "../../../modules/secret-manager"
  }
  variables {
    project_id = "test-project"
    region     = "asia-south1"
    secrets    = { app = { accessors = ["serviceAccount:app@test-project.iam.gserviceaccount.com"] }, regional = { replication_locations = ["asia-south1"] } }
  }
  assert {
    condition     = length(google_secret_manager_secret.secret["app"].replication[0].auto) == 1 && length(google_secret_manager_secret.secret["regional"].replication[0].user_managed[0].replicas) == 1 && length(google_secret_manager_secret_iam_member.accessor) == 1 && google_secret_manager_secret.secret["app"].deletion_protection
    error_message = "The module must preserve its access, security and lifecycle contract."
  }
}
