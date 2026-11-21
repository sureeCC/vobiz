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
    names = plans[enabled]["output_changes"]["resource_names"]["after"]
    firewall = {r["name"]: r for r in resources(enabled, "google_compute_firewall")}
    require(set(firewall) == {names["ingress/allow-app-https"], names["egress/deny-test-egress"]},
            "ingress/egress rules were dropped or renamed")
    ingress = firewall[names["ingress/allow-app-https"]]
    egress = firewall[names["egress/deny-test-egress"]]
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
    require(all(r["project"] == "test-project" and r["network"] == names["vpc"]
                for r in firewall.values()), "firewalls do not target the requested project/VPC")
    networks = resources(enabled, "google_compute_network")
    require(len(networks) == 1 and networks[0]["delete_default_routes_on_create"],
            "default-route deletion flag was dropped")
    ranges = resources(enabled, "google_compute_global_address")
    require(len(ranges) == 1, "expected exactly one PSA reserved range")
    address = ranges[0]
    network_id = "projects/test-project/global/networks/vn-vobiz-prod-asia-south1-001"
    require(address["name"] == names["psa"] and address["prefix_length"] == 20
            and address["purpose"] == "VPC_PEERING" and address["address_type"] == "INTERNAL"
            and address["network"] == network_id and address["project"] == "test-project",
            "PSA address name, size, purpose or network were not forwarded")
    connections = resources(enabled, "google_service_networking_connection")
    require(len(connections) == 1 and connections[0]["network"] == network_id
            and connections[0]["service"] == "servicenetworking.googleapis.com"
            and connections[0]["reserved_peering_ranges"] == [names["psa"]],
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
    inventory = plans["integrated_platform"]["output_changes"]["resource_names"]["after"]
    name_fields = {
        "google_compute_network": "name", "google_compute_subnetwork": "name",
        "google_compute_router": "name", "google_compute_router_nat": "name",
        "google_compute_global_address": "name", "google_redis_instance": "name",
        "google_artifact_registry_repository": "repository_id",
        "google_secret_manager_secret": "secret_id",
    }
    for resource in plans["integrated_platform"]["resource_changes"]:
        if resource["type"] in name_fields and resource["mode"] == "managed":
            actual = resource["change"]["after"][name_fields[resource["type"]]]
            require(actual in inventory.values(), f"resource bypassed generated names: {resource['address']}")
    cache = resources("integrated_platform", "google_redis_instance")[0]
    require(cache["authorized_network"] == network_id and cache["reserved_ip_range"] == inventory["psa"],
            "Redis no longer targets the generated VPC/PSA range")
    references = plans["network_reference_names"]["output_changes"]["resource_names"]["after"]
    nat = resources("network_reference_names", "google_compute_router_nat")[0]
    require(nat["name"] == references["nat/egress"]
            and nat["subnetwork"][0]["name"] == f"projects/test-project/regions/asia-south1/subnetworks/{references['subnet/private']}"
            and nat["subnetwork"][0]["secondary_ip_range_names"] == [
                references["range/private/pods"], references["range/private/services"]],
            "NAT subnet paths or secondary-range names did not follow generated names")
    print("PASS: production names, references, firewall, route policy and PSA graph verified.")
