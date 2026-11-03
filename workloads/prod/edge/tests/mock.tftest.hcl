# Offline tests: every provider is mocked. No GCP reads/writes occur.
mock_provider "google" {
  mock_data "google_compute_network" {
    defaults = {
      name      = "vobiz-prod-vpc"
      self_link = "https://www.googleapis.com/compute/v1/projects/mock-vobiz-project/global/networks/vobiz-prod-vpc"
    }
  }
  mock_data "google_compute_subnetwork" {
    defaults = {
      name      = "vobiz-prod-as1-subnet-gke"
      self_link = "https://www.googleapis.com/compute/v1/projects/mock-vobiz-project/regions/asia-south1/subnetworks/vobiz-prod-as1-subnet-gke"
    }
  }
  mock_data "google_compute_global_address" {
    defaults = { name = "vobiz-prod-private-services" }
  }
  mock_data "google_container_cluster" {
    defaults = {
      endpoint    = "192.0.2.1"
      master_auth = [{ cluster_ca_certificate = "bW9jay1jZXJ0aWZpY2F0ZQ==" }]
    }
  }
  mock_data "google_container_engine_versions" {
    defaults = {
      latest_master_version = "1.34.1-gke.1000000"
      valid_master_versions = ["1.34.1-gke.1000000"]
      valid_node_versions   = ["1.34.1-gke.1000000"]
      release_channel_default_version = {
        REGULAR = "1.34.1-gke.1000000"
        STABLE  = "1.34.1-gke.1000000"
        RAPID   = "1.34.1-gke.1000000"
      }
    }
  }
}
mock_provider "google-beta" {}
mock_provider "random" {}
run "mock_example_plan" {
  command = plan
  variables {
    project_id = "mock-vobiz-project"
  }
  assert {
    condition     = module.https_load_balancer.instance_count == 0 && module.cloud_dns.zone_count == 0 && module.external_addresses.address_count == 0
    error_message = "Public endpoints and DNS must stay disabled in the initial examples."
  }
}

run "mock_enabled_edge_plan" {
  command = plan
  variables {
    project_id                = "mock-vobiz-project"
    enable_http_load_balancer = true
    voice_address_names       = ["mock-voice-ip"]
    dns_zones                 = { mock-zone = { domain = "example.com.", description = "Mock", records = [] } }
    http_backends = {
      default = {
        port                      = 8080
        port_name                 = "http"
        timeout_seconds           = 30
        health_check_path         = "/health"
        instance_group_self_links = ["https://www.googleapis.com/compute/v1/projects/mock-vobiz-project/zones/asia-south1-a/instanceGroups/mock-group"]
      }
    }
  }
}
