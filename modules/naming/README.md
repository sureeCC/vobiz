# Resource naming

Generate provider-free resource names in this format:

```text
<shortcode>-<application>-<environment>-<region>-<three-digit-sequence>
rc-vobiz-prod-eastus-001
sc-vobiz-prod-asia-south1-001
```

Pass application (default vobiz), environment, region and a resources map.
Each inventory key has shortcode, sequence (default 1), optional region override
and optional max_length (default 63). Output names retains the inventory keys.

The production root derives environment with basename(abspath(path.root)), so
workloads/prod produces prod. It passes the configured GCP region unchanged.
Subnet and secondary-range names use the subnet's actual region.

Sequences must be integers 1-999. Names are never silently normalized, truncated
or hashed: invalid context, duplicate names and overlong names fail the plan.
Resource keys do not become name suffixes. Resource numbering is explicit and
does not depend on list/map sort order.

Production shortcode assignments:

| Resource | Shortcode |
|---|---|
| VPC | vn |
| Subnet | sn |
| Secondary IP range | sr |
| Cloud Router | cr |
| Cloud NAT | nt |
| Route | rt |
| Ingress firewall | fi |
| Egress firewall | fe |
| PSA reserved range | pa |
| Artifact Registry | ar |
| Redis cache | rc |
| Secret Manager | sc |

Set root naming_sequences for repeated resources, using keys such as
secret/app, repository/app, subnet/private, range/private/pods, nat/egress,
ingress/allow-https, egress/deny-test, or singleton vpc/router/psa/cache.
Every sequence defaults to 1. If two names collide, assign distinct sequences;
existing assignments must stay fixed as inventory grows. Unknown override keys
are rejected rather than silently ignored.

Physical repository/secret IDs are generated, while their for_each inventory
keys and IAM references stay stable. Networking modules key some resources by
physical names, so adopting the convention can also change those addresses.
The root resolves managed NAT subnet/range references and router/Redis/PSA
network links to the generated resources. External literal NAT subnet paths
and IAM members are not renamed.

Project IDs, API service names, IAM binding IDs, existing state buckets and
GitHub bootstrap identities are outside this module. There is still one state.

Changing physical names may replace resources. For existing deployments,
review the full plan and any address moves/imports; the older moved.tf mappings
only cover the prior folder refactor, not immutable physical-name changes.
