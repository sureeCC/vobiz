mock_provider "google" {}
run "redis_contract" {
  command = plan
  module { source = "./cache" }
  variables {
    project_id        = "test-project"
    region            = "asia-south1"
    network_id        = "projects/test-project/global/networks/test-vpc"
    reserved_ip_range = "test-psa"
    cache = {
      name                 = "test-cache"
      memory_size_gb       = 7
      maintenance_day      = "TUESDAY"
      maintenance_hour_utc = 4
    }
  }
  assert {
    condition     = google_redis_instance.cache.name == "test-cache" && google_redis_instance.cache.memory_size_gb == 7 && google_redis_instance.cache.tier == "STANDARD_HA" && google_redis_instance.cache.auth_enabled && google_redis_instance.cache.transit_encryption_mode == "SERVER_AUTHENTICATION" && google_redis_instance.cache.deletion_protection
    error_message = "Redis must forward capacity and preserve HA, AUTH, TLS and deletion protection."
  }
  assert {
    condition     = google_redis_instance.cache.authorized_network == "projects/test-project/global/networks/test-vpc" && google_redis_instance.cache.reserved_ip_range == "test-psa" && google_redis_instance.cache.connect_mode == "PRIVATE_SERVICE_ACCESS" && google_redis_instance.cache.maintenance_policy[0].weekly_maintenance_window[0].start_time[0].hours == 4
    error_message = "Redis must use the supplied private network, PSA range and maintenance window."
  }
}
