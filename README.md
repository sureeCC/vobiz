# Vobiz GCP Terraform

Integrated on 3 November 2026 from the local validated scaffold and the repository's
`feature/networking-module` branch. This branch contains infrastructure source and
mock examples only. No infrastructure has been deployed.

## Repository layout and state

| Layer | Entry point | GCS state prefix | Owner / purpose |
|---|---|---|---|
| bootstrap | `landing-zone/bootstrap` | `bootstrap` after migration | State bucket in an existing administrative project |
| foundation | `landing-zone/organization` | `prod/foundation` | Production project, APIs, additive IAM and optional project policies |
| network | `workloads/prod` | `prod/network` | Network engineer: VPC, subnets, firewall, optional PSA and egress router/NAT |
| gke | `workloads/prod/gke` | `prod/gke` | Private regional GKE through `modules/gke` |
| platform | `workloads/prod/platform` | `prod/platform` | Registry, secret containers, Argo CD, monitoring; optional KMS/build triggers |
| connectivity | `workloads/prod/connectivity` | `prod/connectivity` | Optional GCP AWS-VPN gateway and separate BGP router |
| edge | `workloads/prod/edge` | `prod/edge` | Optional DNS, IPs and instance-group HTTPS LB |
| voice | `workloads/prod/voice` | `prod/voice` | Optional explicitly selected SIP/carrier VMs |
| data | `workloads/prod/data` | `prod/data` | Later PostgreSQL HA/read replica, Redis and buckets |

`landing-zone/organization` configures a project and project policies, not an entire
GCP organization or folder hierarchy. Shared local networking modules remain in
`modules/networking`; reusable GKE code is in `modules/gke`. Public upstream modules
have exact version pins. Google/Google Beta providers are pinned to 7.46.1 across
roots. The networking branch previously requested Google 8.x, but pinned platform modules
require Google <8; 7.46.1 satisfies the integrated constraints.
Provider configurations and backends belong to deployment roots, not GKE's
reusable module. Commit each root's `.terraform.lock.hcl`.

The parent `workloads/prod` directory is the network root. Terraform does not load
`.tf` files in its subdirectories. Each root uses separate state; never run a
recursive apply. `scripts/layout.py` is the authoritative root-path mapping.

## Initial deployment

Order: bootstrap -> foundation -> network-owner handoff -> GKE -> platform.
Run the network root only if this repository is the agreed owner. When another
repository/state already owns the network, skip it and configure GKE with the
existing network and subnet names. No duplicate VPC/subnet/NAT ownership is allowed.
Cross-layer lookups use names and data sources, not full remote-state access.

```powershell
python scripts/deploy.py prepare
python scripts/deploy.py preflight --layer gke
python scripts/deploy.py init --layer gke
python scripts/deploy.py plan --layer gke
```

Prepare copies examples without overwriting existing configuration. Replace all
mock IDs, IAM identities, names, IPs and capacity settings. The literal `PROJECT ID`
blocks a real plan. Common production inputs live in `workloads/prod/common.tfvars`;
layer inputs and backend configuration live in each root. See [DEPLOYMENT.md](DEPLOYMENT.md).

## Local checks

Terraform 1.16.6 and Python 3 are required. These commands download public modules
and providers but do not authenticate to a cloud backend or call GCP APIs:

```powershell
terraform fmt -check -recursive
python scripts/validate.py --mock-plan
```

See [VALIDATION.md](VALIDATION.md) for integration results and limits.

## Delivery boundaries

- Network configuration belongs to the network engineer. See [NETWORK_HANDOFF.md](NETWORK_HANDOFF.md).
- Example CIDRs and node capacity are unapproved. Validate AWS/carrier overlap,
  quotas, scale, zone failure and active-call draining before production use.
- Platform requires a pre-existing runner with private GKE API access and the
  Google authentication plugin. Provider impersonation does not authenticate the
  GCS backend or Kubernetes plugin; configure their identities separately.
- Secret Manager resources are empty containers; populate versions externally.
- AWS databases remain authoritative initially; data services and VPN/edge/voice
  examples are disabled or empty. This repository never changes AWS resources.
- Argo CD bootstrap is included. Application images, manifests, repository access,
  Applications, scaling policies and GKE Gateway routes remain delivery inputs.
- Optional Terraform HTTPS load balancing is not the GKE Gateway configuration;
  keep it disabled when GKE owns ingress. SIP/RTP requires separate reviewed paths.
- If adopting existing resources, reconcile/import state first. Existing deployed
  states cannot be relocated to this layout without a reviewed state migration.

The original `C:/vobiz/terraform` scaffold is preserved outside this repository.
