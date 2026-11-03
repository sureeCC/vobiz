# Network ownership and GKE handoff

The network engineer owns `workloads/prod` and `modules/networking`. That root
creates a VPC through the existing public network module wrapper. Other roots
never create a VPC. Skip the network root when the network is owned elsewhere.
Never import or apply a second state over externally owned networking.

Provide GKE with the actual project, region, VPC name, subnet name, Pod secondary
range name and Service secondary range name. The mock examples align as follows:

| Input | Example only |
|---|---|
| Region | `asia-south1` |
| VPC | `vobiz-prod-vpc` |
| GKE subnet | `vobiz-prod-as1-subnet-gke`, `10.80.0.0/20` |
| Pod secondary range | `vobiz-prod-as1-range-pods`, `10.84.0.0/16` |
| Service secondary range | `vobiz-prod-as1-range-services`, `10.85.0.0/20` |
| Voice subnet | `vobiz-prod-as1-subnet-voice`, `10.80.16.0/24` |
| Control-plane reservation | `10.80.17.0/28`; reserved separately, not a subnet to create |

Approve actual CIDRs against AWS/carrier ranges. Confirm private Google API access,
Git/image egress, DNS, MTU, firewall and runner-to-private-GKE API connectivity.
Examples create no additional ingress rules; workload-specific rules need review.

The network root owns its declared firewall rules, default-route settings, PSA and
egress Cloud Router/NAT. `create_router=false` omits the egress router and NATs.
Logging and subnet selection are configured in `nats`, not separate legacy inputs.
The router uses the VPC module output to enforce dependency ordering.

Network root outputs include `network_name`, `network_id`, `subnets`, subnet IDs,
names and secondary ranges, plus `router` and `nat`. Copy reviewed resource names
into downstream layer inputs; downstream data lookups do not deploy this root.

Later SQL/Redis needs network-owned PSA enabled first. Connectivity owns its VPN
router separately, only when delegated. AWS peer configuration and carrier changes
remain external. Shared VPC across projects is not configured by this template.

The networking example changed names/CIDRs and now wires previously ignored inputs.
If its previous branch was applied, review every resulting diff and any imports or
state changes before applying. No existing deployment is assumed absent.

A moved block preserves `module.cloud_router` as `module.cloud_router[0]` when
router creation is enabled. It does not approve example-name/CIDR replacements or
transfer ownership from any other state.
