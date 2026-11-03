# Resource module catalog

Resource definitions live here. Deployment folders under `landing-zone` and
`workloads/prod` call these modules, supply environment settings and own separate
state. Run Terraform from a deployment root, not directly from these directories.

| Module | Resources / purpose |
|---|---|
| [networking/vnet](networking/vnet/) | VPC, subnets, routes, firewall and optional Private Service Access |
| [networking/cloud-router](networking/cloud-router/) | Egress Cloud Router and Cloud NAT |
| [gke](gke/) | Private regional GKE cluster, node identity and configurable pools |
| [project](project/) | Project creation/adoption, APIs, IAM, audit configuration and project policies |
| [project-services](project-services/) | Explicit API enablement for a project |
| [state-bucket](state-bucket/) | Private versioned Terraform state bucket and storage administrators |
| [artifact-registry](artifact-registry/) | Docker image repositories and repository IAM |
| [secret-manager](secret-manager/) | Empty secret containers and explicit secret accessor IAM |
| [workload-identity](workload-identity/) | Project grants and Kubernetes-to-Google service-account links |
| [argocd](argocd/) | Argo CD namespace and Helm release; caller supplies Helm values |
| [logging](logging/) | Log bucket, sink and writer grant |
| [monitoring](monitoring/) | Notification channels and GKE container-restart alert |
| [cloud-build](cloud-build/) | Repository-connected image build triggers |
| [kms](kms/) | Optional key ring and symmetric encryption keys |
| [cloud-sql](cloud-sql/) | Optional private PostgreSQL HA instance and in-region read replica |
| [redis](redis/) | Optional private HA Redis with AUTH and encrypted transit |
| [cloud-storage](cloud-storage/) | Private storage buckets with versioning controls |
| [dns](dns/) | Public DNS zones and explicit records |
| [external-addresses](external-addresses/) | Standalone regional public IP reservations |
| [https-load-balancer](https-load-balancer/) | Optional HTTPS frontend, certificate and baseline Cloud Armor policy |
| [ha-vpn](ha-vpn/) | Optional GCP HA VPN, dedicated router and AWS peer/BGP configuration |
| [voice-vm](voice-vm/) | Explicit voice VM inventory, templates, identity and optional public IPs |

Modules use version-pinned public Google modules where appropriate and native
resources for supporting configuration. They contain no backend or provider
configuration. Credentials, labels and provider identities come from the caller.

The existing deployment-layer grouping (`platform`, `edge`, `voice`, `data`) is
retained for state ownership; it is not the module catalog. Module inputs have
explicit types in `variables.tf`; outputs are in `outputs.tf`. Mock plan tests run
through deployment roots to verify how the modules are connected.

For example, the platform root calls the registry resource module:

```hcl
module "artifact_registry" {
  source       = "../../../modules/artifact-registry"
  project_id   = var.project_id
  region       = var.region
  labels       = var.labels
  repositories = var.repositories
}
```

State `moved` blocks in deployment roots map former inline addresses into modules.
Review a real plan before using these mappings with an existing deployment; mock
plans verify configuration and do not prove a live state's migration is safe.
