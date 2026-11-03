# Integration validation — 3 November 2026

Validated on branch `codex/align-terraform-modules`, based on networking commit
`a338e51`, using Terraform 1.16.6. The original local scaffold remains unchanged.

## Results

- Repository-wide `terraform fmt -check -recursive` passed.
- All nine deployment roots passed backend-free initialization and
  `terraform validate`, each with zero schema-validation warnings.
- All 16 provider-mocked plans passed. Every provider is mocked; no GCP API calls
  or backend authentication occur in these plans.
- Networking was rerun after adding the router address-migration block and the
  enabled default-route policy test; all three cases passed.
- The deployment helper's nine-root mapping, non-overwriting prepare behavior,
  bootstrap handling, mock-value rejection and complete-input acceptance passed
  isolated temporary-directory checks. Python compilation passed.
- `git diff --check` passed. Nine provider lock files are included; downloaded
  modules/providers, real inputs, plans and state are ignored.

| Layer | Mock plans | Coverage |
|---|---:|---|
| bootstrap | 1 | State bucket |
| foundation | 1 | Existing-project foundation |
| network | 3 | VPC/NAT; router disabled; firewall/PSA/default-route policy enabled |
| gke | 1 | Reusable private regional GKE module through workload root |
| platform | 2 | Registry/secrets/Argo CD/monitoring; explicit workload identity grants |
| connectivity | 2 | Disabled example and enabled four-tunnel topology |
| edge | 2 | Disabled example and enabled HTTPS/DNS/IP configuration |
| voice | 2 | Empty inventory and enabled VM configuration |
| data | 2 | Disabled example and enabled PostgreSQL/Redis/buckets |

## Compatibility decisions

The repository networking branch requested Google 8.x. Initialization of the
integrated platform failed because its pinned upstream modules require Google <8.
All Google and Google Beta provider constraints were therefore standardized on
7.46.1, which passes the complete integrated suite. Public module versions are
exactly pinned rather than using the networking branch's floating minor ranges.

Networking mock plans emit non-blocking upstream deprecation warnings when the
existing `subnets` output exposes the provider's `fingerprint` attribute. The output
contract was preserved. These warnings are distinct from schema validation, which
reports zero warnings; they do not indicate failed plans.

## Scope and remaining work

This integration moves the local roots into the repository layout, populates the
GKE module, retains and repairs networking wrappers, and updates documentation and
operator helpers. Root state prefixes remain separate. A moved block preserves the
router module address when enabling its newly functional creation switch.

No live backend initialization, cloud plan/apply, AWS change, secret publication,
workload migration occurred during validation. Publishing the source branch is a
separate Git operation and does not deploy infrastructure. Mock checks do not verify live IAM,
APIs, quotas, network/carrier behavior, Helm connectivity or application readiness.

Real project/backend/IAM values, network-owner approval and handoff, approved node
capacity, private runner access, application manifests and secrets remain required.
New-project foundation and optional KMS/build triggers pass schema checks but have
not been exercised by enabled mock cases. Review existing resource/state ownership
and all example name/CIDR changes before any deployment.

Reproduce from the repository root:

```powershell
terraform fmt -check -recursive
python scripts/validate.py --mock-plan
```
