"""Verify firewall and PSA resources in the actual production mocked plans."""


def verify_network_security(plans):
    def resources(run, kind):
        return [r["change"]["after"] for r in plans[run]["resource_changes"]
                if r["mode"] == "managed" and r["type"] == kind]

    def require(condition, message):
        if not condition:
            raise ValueError(f"Network security graph: {message}")

    required = {"security_and_psa", "production_networking", "firewall_without_psa"}
    require(required <= plans.keys(), "required production test plans are missing")
    enabled = "security_and_psa"
    firewall = {r["name"]: r for r in resources(enabled, "google_compute_firewall")}
    require(set(firewall) == {"allow-app-https", "deny-test-egress"},
            "ingress/egress rules were dropped or renamed")
    ingress = firewall["allow-app-https"]
    egress = firewall["deny-test-egress"]
    require(ingress["direction"] == "INGRESS" and ingress["source_ranges"] == ["10.80.0.0/20"]
            and ingress["allow"] == [{"protocol": "tcp", "ports": ["443"]}]
            and ingress["priority"] == 900 and ingress["target_tags"] == ["app"]
            and ingress["log_config"][0]["metadata"] == "INCLUDE_ALL_METADATA",
            "ingress ranges, ports, priority, targets or logging were not forwarded")
    require(egress["direction"] == "EGRESS" and egress["destination_ranges"] == ["203.0.113.0/24"]
            and egress["deny"][0]["protocol"] == "all"
            and egress["target_tags"] == ["app"] and egress["priority"] == 1000
            and egress["log_config"][0]["metadata"] == "EXCLUDE_ALL_METADATA",
            "egress destinations, deny action, priority, targets or logging were not forwarded")
    require(all(r["project"] == "test-project" and r["network"] == "test-vpc"
                for r in firewall.values()), "firewalls do not target the requested project/VPC")
    networks = resources(enabled, "google_compute_network")
    require(len(networks) == 1 and networks[0]["delete_default_routes_on_create"],
            "default-route deletion flag was dropped")
    ranges = resources(enabled, "google_compute_global_address")
    require(len(ranges) == 1, "expected exactly one PSA reserved range")
    address = ranges[0]
    network_id = "projects/test-project/global/networks/test-vpc"
    require(address["name"] == "test-private-services" and address["prefix_length"] == 20
            and address["purpose"] == "VPC_PEERING" and address["address_type"] == "INTERNAL"
            and address["network"] == network_id and address["project"] == "test-project",
            "PSA address name, size, purpose or network were not forwarded")
    connections = resources(enabled, "google_service_networking_connection")
    require(len(connections) == 1 and connections[0]["network"] == network_id
            and connections[0]["service"] == "servicenetworking.googleapis.com"
            and connections[0]["reserved_peering_ranges"] == ["test-private-services"],
            "PSA connection is not linked to the requested network and range")
    apis = resources(enabled, "google_project_service")
    require({r["service"] for r in apis} == {"compute.googleapis.com", "servicenetworking.googleapis.com"}
            and all(not r["disable_on_destroy"] for r in apis),
            "PSA APIs were dropped or will be disabled on removal")
    for run in ["production_networking", "firewall_without_psa"]:
        require(not resources(run, "google_compute_global_address")
                and not resources(run, "google_service_networking_connection"),
                f"PSA resources unexpectedly created in {run}")
    require(not resources("production_networking", "google_compute_firewall"),
            "empty rule lists unexpectedly create firewall rules")
    require(not resources("production_networking", "google_compute_network")[0]["delete_default_routes_on_create"],
            "default configuration deletes internet routes")
    require(len(resources("firewall_without_psa", "google_compute_firewall")) == 1,
            "firewall configuration depends incorrectly on PSA")
    print("PASS: production firewall, route policy and PSA resource graph verified.")
