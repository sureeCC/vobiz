# Vobiz infrastructure

Production has one Terraform root, one GCS backend and one state. Component
folders are child modules loaded by the root:

```text
workloads/prod/
  backend.tf              # Existing vobiz-terraform / terraform-state/prod
  providers.tf            # Provider configuration stays in the root
  main.tf                 # Calls ./networking
  variables.tf            # Production inputs
  outputs.tf              # Existing public outputs
  moved.tf                # Existing module address migration
  registry/               # Docker repositories and repository IAM
  cache/                  # Private Memorystore Redis
  secrets/                # Secret containers and accessor IAM
  networking/
    main.tf               # VPC and Cloud Router/NAT calls
    variables.tf
    outputs.tf
    versions.tf
  tests/
tools/terraform_pipeline.py
.github/workflows/terraform-prod.yml
```

Reusable implementations remain in modules/networking. GKE and organization
directories are empty scaffolds. Naming remains explicitly caller-supplied.

## Local use

Install Terraform 1.16.6 and Python 3.12 or newer. Run from the repository root:

```powershell
python tools/terraform_pipeline.py validate
python -m unittest discover -s tools/tests -v
python tools/terraform_pipeline.py plan --var-file workloads/prod/terraform.tfvars
# Review the printed plan before applying:
python tools/terraform_pipeline.py apply
```

Prepare workloads/prod/terraform.tfvars from your existing reviewed inputs and
the checked-in terraform.tfvars.example. The runner resolves input paths from
the current directory and always runs Terraform in workloads/prod using the
default CLI workspace. It creates artifacts/prod.tfplan and applies that saved
plan. Backend locking is enabled with a five-minute wait. Validation initializes
without the live backend and uses provider mocks; plan/apply require Google ADC
and permissions on both project resources and the existing state bucket.

Do not initialize or apply inside component folders, or add component backends.
Future component folders need a module call in the root. All components must be
included in the same plan; the runner has no component or target selector.

## GitHub Actions

All pull requests targeting main run formatting, schema validation, mocked
Terraform tests and Python tests without cloud credentials. Same-repository PR
runs triggered by the repository owner also generate a real production plan
using the plan service account. Forks, Dependabot and other actors skip cloud
planning. The plan appears in logs and its counts appear in the Actions job
summary. PRs never apply and do not upload the binary plan.

Dispatch Production Terraform on main to create a full production plan. Enable the apply input to continue to the production
environment approval and then apply the same run's saved plan.

Configure these repository variables:
- GCP_WIF_PROVIDER: GitHub-to-Google Workload Identity Federation provider.
- GCP_PLAN_SERVICE_ACCOUNT: plan identity with resource read and state locking access.
- GCP_APPLY_SERVICE_ACCOUNT: apply identity with resource management and state access.
  Leave unset for plan-only operation.
- TF_STATE_BUCKET: the existing Terraform state bucket to use.
- TF_STATE_PREFIX: the shared object prefix, normally terraform-state/prod.

Set repository secret PROD_TFVARS_HCL to the complete production Terraform inputs.
Configure the GitHub environment production with required reviewers and deployment
restricted to main. Restrict federation trust to this repository and intended
workflow/ref. Account permissions and environment protection are external setup;
this change does not create them. Saved plans and logs may contain sensitive
values; restrict repository access. Plan artifacts are retained for one day.
Deployments share one concurrency group and Terraform also locks the GCS state.

## Existing deployments

The backend bucket and prefix are unchanged. Keep moved.tf: it maps module.vpc to
module.networking.module.vpc and module.cloud_router to
module.networking.module.cloud_router, including their child resources.
Review a full plan against the existing state before the first apply; this
refactor should show address moves with unchanged resource settings. No live
state has been inspected or modified during this change.

Existing behavior is retained: router creation is unconditional despite the
legacy create_router variable; the router network comes from the network input.
Firewall, PSA and default-route deletion inputs now flow through both VPC
wrappers to the upstream network module.


## Registry, application cache and secrets

These components are child modules under workloads/prod and use the existing
backend, pipeline and saved production plan. Repository and secret map keys are
physical resource IDs. Shared project/region inputs configure all Google
providers, and labels apply to the new platform resources.

Merge the platform inputs in workloads/prod/terraform.tfvars.example into your
existing production tfvars. Keep current network/router names and IP ranges.
The example creates one Docker repository, one 5 GiB HA Redis instance and one
regional secret container. Defaults are empty repository/secret maps and a null
cache, so existing input files keep their current inventory until configured.

Artifact Registry uses immutable Docker tags by default. Give node/pull
identities repository reader access and build identities writer access through
the readers/writers sets. These are additive, repository-scoped IAM grants.

Redis uses the root VPC, PRIVATE_SERVICE_ACCESS, AUTH and TLS. Enable the
private_service_access_config connection and choose a reviewed reserved range.
Redis waits for the VPC/PSA module to finish; required project APIs are enabled
first and are not disabled on removal. The root now wires the existing PSA
inputs into the network module. If this VPC already has a PSA connection or
reserved range managed elsewhere, reconcile/import its ownership before applying.
Redis defaults to STANDARD_HA, REDIS_7_2 and Sunday 03:00 UTC maintenance.

Secret Manager accepts container definitions, replication locations and
resource-scoped accessor members. An empty location set selects automatic
replication. Populate secret versions outside Terraform; no secret payload input
or secret-version resource is provided. Redis and secrets have deletion
protection enabled. Removing those resources requires deliberately disabling
protection in configuration and applying that change first.

Outputs include registry_docker_urls, registry_repository_ids, secrets_secret_ids,
cache_host, cache_port and cache_server_ca_certs. Redis AUTH is not exported;
provider-managed credentials can still exist in state. Applications must use
TLS and retrieve credentials through an authorized runtime process.

The apply identity additionally needs permission to enable project services and
manage Artifact Registry, Memorystore, Secret Manager, their scoped IAM grants,
and the PSA connection/reserved range. No service-account keys are created.


## Network security and private service connectivity

Configure ingress_rules and egress_rules in the root production tfvars. Both
are forwarded through workloads/prod/networking and modules/networking/vnet.
Rules preserve their supplied names, directions, ranges, allow/deny protocols,
ports, priority, target tags or service accounts, and logging configuration.
Empty lists add no explicit firewall rules. The example leaves them empty;
define rules for your actual workload sources and targets.

private_service_access_config creates one internal VPC_PEERING reserved IP
range and its servicenetworking.googleapis.com connection to the production VPC.
address_name and prefix_length are passed through unchanged. Compute and Service
Networking APIs are enabled before PSA; firewall-only configuration enables
Compute without creating PSA. Redis waits for networking and PSA readiness.

delete_default_internet_gateway_routes is now forwarded to the network module.
Its default remains false; the provider uses this as the network's default-route
deletion-on-creation setting. Keep deliberate internet routes/NAT requirements in
your reviewed configuration.

Previously supplied firewall inputs now take effect in the next plan. Review
those rules before applying. Existing PSA connections or reserved ranges owned
elsewhere need ownership reconciliation/import rather than duplicate creation.

The Python validation command checks the actual production mocked resource
plans for firewall fields, default-route policy, PSA network/range linkage and
API lifecycle, in addition to Terraform's test assertions.


GitHub writes an explicit backend.hcl from TF_STATE_BUCKET and TF_STATE_PREFIX
for both plan and apply. These override the checked-in backend defaults without
migrating existing state. Local runs can pass --backend-config workloads/prod/backend.hcl
to select the same bucket. Keep the original backend defaults for existing Vobiz
deployments. Tainytails uses a separate bucket and the same single-state layout.

The current Tainytails GitHub configuration is plan-only: GCP_APPLY_SERVICE_ACCOUNT
is intentionally unset. Selecting apply fails before cloud authentication until
an apply account and its production approval setup are explicitly configured.


GitHub federation accepts the main workflow_dispatch context and owner-triggered
pull_request runs targeting main, with the expected repository/owner numeric
IDs and exact workflow path/ref. The plan account uses the repository-ID
attribute for impersonation, so GitHub's legacy and immutable subject formats
both work. Expanding cloud planning to additional collaborators requires
updating both the workflow actor filter and the GCP provider condition.
