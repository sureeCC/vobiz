# Offline verification ? 15 November 2026

Branch: `feature/all-public-modules`. No real GCP or Kubernetes resources were
created, planned against, modified or destroyed. Existing networking files remain
unchanged. The five new roots retain their ignored local backend overrides.

## Results

| Check | Result |
|---|---|
| Formatting and Terraform validation | Passed for all five module/root pairs |
| Terraform scenarios | 22 passed: cache 5, registry 4, secrets 4, identity 4, Argo CD 5 |
| Deployment-root resource graph checks | Passed for all five roots |
| Saved-plan safeguards | 12 Python tests passed |
| Fresh checkout simulation | All five roots initialized with read-only locks and passed checks without local overrides or previous .terraform data |
| Broken root wiring regression | Replacing root registry inputs with an empty map was correctly rejected |
| Workflow syntax | actionlint passed for both workflows |
| Shell syntax | bash -n passed for 12 workflow run steps |
| Actual Argo CD chart rendering | Chart 10.18.0 rendered 60 resources for Kubernetes 1.32 using actual mock-plan Helm values; CRDs and Deployments present, no LoadBalancer service |
| Lock-file coverage | Google 8.9.0 and Helm 3.3.0 locks contain signed upstream checksums for Windows/Linux |

Local tests used Terraform 1.16.6, Google provider 8.9.0 and Helm provider 3.3.0.
The chart render used Helm 3.18.6, downloaded from the official Helm distribution
and checked against its published SHA-256. Rendering validates templates, not
admission, live CRD installation or controller health.

## What is covered

- Real deployment roots are now mock-planned, in addition to direct module tests.
  The validator inspects Terraform's JSON resource plans for forwarding of VPC,
  cache size/maintenance, repository readers/writers, secret IDs/replication,
  workload identity subjects/roles, Argo namespace and custom Helm values.
- API configuration, cache HA/AUTH/TLS/protection, secret deletion protection,
  resource-scoped IAM, no service-account keys and no secret version payloads.
- Placeholder project IDs, invalid cache size/hour, malformed/non-mapping Helm
  values, and empty inventories. These tests do not authenticate to Google.
- Saved-plan manifest verification accepts matching plans and rejects changes to
  the plan, backend or lock; wrong layer/commit; expired/future timestamps; and
  missing files. Project checks reject mismatched input/resource/deletion projects,
  unknown resource projects and a changed apply-environment project. Saved plans must be at most 24 hours old.
- Deployment now depends on credential-free checks, uses distinct plan/apply
  environments, applies the saved plan without replanning, and cleans local
  plan/config files afterward. Required GitHub environment reviewers must still
  be configured externally.

## Reproduce

```powershell
python -m unittest discover -s tools/tests -v
python tools/check_terraform.py
```

The helper initializes with `-backend=false -lockfile=readonly`, validates, and
executes mocked plans. An optional `--plugin-dir` supports an existing local
provider mirror. Tests stop with a nonzero exit code on failure and each command
has a timeout. Provider downloads require network access unless mirrored locally.

## Not verified without real infrastructure

No GCP project, VPC/PSA connection, GKE cluster, ADC credentials or GitHub OIDC
configuration is available. Consequently these remain deployment prerequisites:

- Cloud IAM permissions, API enablement propagation, quotas, resource availability
  and service-account propagation.
- Actual PSA/network connectivity and Redis TLS/AUTH client access.
- GKE Workload Identity enablement, node image-pull access, Kubernetes service
  account annotations and workload access to individual secrets.
- Private GKE API reachability, authentication-plugin execution, Kubernetes RBAC,
  live Helm rollout/CRD health, Argo CD SSO and application bootstrap.
- GCS backend access and locking, GitHub OIDC exchange, real plan/apply artifacts,
  environment reviewer protections and runner isolation on GitHub Actions.

A successful offline result is not evidence of a successful cloud deployment.
Run reviewed live plans only after these prerequisites exist. No apply is needed
or attempted for the offline checks above.
