mock_provider "google" {}
run "secret_contract" {
  command = plan
  module { source = "./secrets" }
  variables {
    project_id = "test-project"
    region     = "asia-south1"
    secrets = {
      app      = { accessors = ["serviceAccount:app@test-project.iam.gserviceaccount.com"] }
      regional = { replication_locations = ["asia-south1"] }
    }
  }
  assert {
    condition     = google_secret_manager_secret.secret["app"].deletion_protection && length(google_secret_manager_secret.secret["app"].replication[0].auto) == 1 && google_secret_manager_secret.secret["regional"].replication[0].user_managed[0].replicas[0].location == "asia-south1"
    error_message = "Secret replication and deletion protection must be preserved."
  }
  assert {
    condition     = length(google_secret_manager_secret_iam_member.accessor) == 1 && values(google_secret_manager_secret_iam_member.accessor)[0].role == "roles/secretmanager.secretAccessor" && values(google_secret_manager_secret_iam_member.accessor)[0].member == "serviceAccount:app@test-project.iam.gserviceaccount.com"
    error_message = "Secret access must be granted only to the configured identity."
  }
}
