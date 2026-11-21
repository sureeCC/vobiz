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

run "production_networking" {
  command = plan
  assert {
    condition     = output.network_name == "test-vpc" && length(output.subnets_names) == 1 && output.subnets_names[0] == "private"
    error_message = "Root outputs must preserve network and subnet names through the child module."
  }
}

run "security_and_psa" {
  command = plan
  variables {
    delete_default_internet_gateway_routes = true
    ingress_rules = [{
      name          = "allow-app-https"
      priority      = 900
      source_ranges = ["10.80.0.0/20"]
      target_tags   = ["app"]
      allow         = [{ protocol = "tcp", ports = ["443"] }]
      log_config    = { metadata = "INCLUDE_ALL_METADATA" }
    }]
    egress_rules = [{
      name               = "deny-test-egress"
      priority           = 1000
      destination_ranges = ["203.0.113.0/24"]
      target_tags        = ["app"]
      deny               = [{ protocol = "all" }]
      log_config         = { metadata = "EXCLUDE_ALL_METADATA" }
    }]
    private_service_access_config = {
      enable_private_services_connection = true
      address_name                       = "test-private-services"
      prefix_length                      = 20
    }
  }
  assert {
    condition     = toset(keys(google_project_service.platform)) == toset(["compute.googleapis.com", "servicenetworking.googleapis.com"])
    error_message = "PSA must enable Compute and Service Networking even without Redis."
  }
}
run "firewall_without_psa" {
  command = plan
  variables {
    ingress_rules = [{
      name          = "allow-app-https"
      source_ranges = ["10.80.0.0/20"]
      target_tags   = ["app"]
      allow         = [{ protocol = "tcp", ports = ["443"] }]
    }]
  }
  assert {
    condition     = toset(keys(google_project_service.platform)) == toset(["compute.googleapis.com"])
    error_message = "Firewall-only configuration must enable Compute without adding PSA."
  }
}
