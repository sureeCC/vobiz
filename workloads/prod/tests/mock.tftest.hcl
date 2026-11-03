mock_provider "google" {}
mock_provider "google-beta" {}
run "network_and_nat" {
  command = plan
  variables { project_id = "mock-vobiz-project" }
  assert {
    condition     = length(module.cloud_router) == 1 && length(output.subnets_names) == 2
    error_message = "The network handoff and enabled egress router must be present."
  }
}
run "without_router" {
  command = plan
  variables {
    project_id    = "mock-vobiz-project"
    create_router = false
    nats          = []
  }
  assert {
    condition     = output.router == null && output.nat == null
    error_message = "Disabling router creation must leave no router/NAT outputs."
  }
}
run "network_policy_features" {
  command = plan
  variables {
    delete_default_internet_gateway_routes = true
    project_id                             = "mock-vobiz-project"
    ingress_rules                          = [{ name = "allow-private-test", source_ranges = ["10.80.0.0/20"], allow = [{ protocol = "tcp", ports = ["443"] }] }]
    egress_rules                           = [{ name = "deny-egress-test", destination_ranges = ["203.0.113.0/24"], deny = [{ protocol = "all" }] }]
    private_service_access_config          = { enable_private_services_connection = true, address_name = "vobiz-prod-private-services", prefix_length = 16 }
  }
}
