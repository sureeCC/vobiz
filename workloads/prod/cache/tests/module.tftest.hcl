mock_provider "google" {}
run "module_contract" {
  command = plan
  module {
    source = "../../../modules/redis"
  }
  variables {
    project_id = "test-project"
    region     = "asia-south1"
    name       = "test-cache"
    network_id = "projects/test-project/global/networks/prod-vpc"
  }
  assert {
    condition     = google_redis_instance.cache.auth_enabled && google_redis_instance.cache.transit_encryption_mode == "SERVER_AUTHENTICATION" && google_redis_instance.cache.tier == "STANDARD_HA" && google_redis_instance.cache.deletion_protection
    error_message = "The module must preserve its access, security and lifecycle contract."
  }
}
