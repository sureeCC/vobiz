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
    condition     = length(module.aws_vpn) == 0
    error_message = "Mock peer IPs must never enable a VPN by default."
  }
}

run "mock_enabled_vpn_plan" {
  command = plan
  variables {
    project_id     = "mock-vobiz-project"
    enable_aws_vpn = true
    tunnel_shared_secrets = {
      tunnel-0 = "MOCK-ONLY-NOT-A-REAL-SECRET-0000"
      tunnel-1 = "MOCK-ONLY-NOT-A-REAL-SECRET-0001"
      tunnel-2 = "MOCK-ONLY-NOT-A-REAL-SECRET-0002"
      tunnel-3 = "MOCK-ONLY-NOT-A-REAL-SECRET-0003"
    }
  }
}
