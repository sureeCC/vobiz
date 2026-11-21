mock_provider "google" {}
mock_provider "google-beta" {
  mock_resource "google_compute_network" {
    override_during = plan
    defaults = {
      id        = "projects/test-project/global/networks/test-vpc"
      self_link = "https://www.googleapis.com/compute/v1/projects/test-project/global/networks/test-vpc"
    }
  }
}

variables {
  repositories = {
    app = {
      readers = ["serviceAccount:node@test-project.iam.gserviceaccount.com"]
      writers = ["serviceAccount:build@test-project.iam.gserviceaccount.com"]
    }
  }
  secrets = {
    app      = { accessors = ["serviceAccount:app@test-project.iam.gserviceaccount.com"] }
    regional = { replication_locations = ["asia-south1"] }
  }
  cache  = { name = "test-cache", memory_size_gb = 7 }
  labels = { environment = "test" }
  private_service_access_config = {
    enable_private_services_connection = true
    address_name                       = "test-psa"
    prefix_length                      = 16
  }
  project_id   = "test-project"
  network_name = "test-vpc"
  region       = "asia-south1"
  subnets = [{
    subnet_name   = "private"
    subnet_ip     = "10.80.0.0/20"
    subnet_region = "asia-south1"
  }]
  secondary_ranges   = {}
  routes             = []
  router_name        = "test-router"
  router_description = "Test router"
  network            = "projects/test-project/global/networks/test-vpc"
  nats = [{
    name                               = "test-nat"
    nat_ip_allocate_option             = "AUTO_ONLY"
    source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  }]
}


run "integrated_platform" {
  command = plan
  assert {
    condition     = output.registry_docker_urls["app"] == "asia-south1-docker.pkg.dev/test-project/app" && length(output.secrets_secret_ids) == 2 && length(module.cache) == 1
    error_message = "The production plan must include registry, secrets and Redis together."
  }
}
run "empty_platform" {
  command = plan
  variables {
    repositories = {}
    secrets      = {}
    cache        = null
    private_service_access_config = {
      enable_private_services_connection = false
      address_name                       = "test-psa"
      prefix_length                      = 16
    }
  }
  assert {
    condition     = length(output.registry_repository_ids) == 0 && length(output.secrets_secret_ids) == 0 && output.cache_host == null && length(google_project_service.platform) == 0
    error_message = "Omitting platform inputs must not add platform resources or API ownership."
  }
}
run "cache_requires_psa" {
  command = plan
  variables {
    private_service_access_config = {
      enable_private_services_connection = false
      address_name                       = "test-psa"
      prefix_length                      = 16
    }
  }
  expect_failures = [var.cache]
}
run "invalid_memory" {
  command = plan
  variables { cache = { name = "test-cache", memory_size_gb = 0 } }
  expect_failures = [var.cache]
}
run "invalid_tier" {
  command = plan
  variables { cache = { name = "test-cache", tier = "INVALID" } }
  expect_failures = [var.cache]
}
run "invalid_maintenance_hour" {
  command = plan
  variables { cache = { name = "test-cache", maintenance_hour_utc = 24 } }
  expect_failures = [var.cache]
}
