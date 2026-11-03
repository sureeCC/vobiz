# Deployment workflow

Run commands from the repository root. All real values remain outside Git.

1. Run `python scripts/deploy.py prepare`. Edit `workloads/prod/common.tfvars`,
   each selected layer's `terraform.tfvars` and its `backend.hcl`. See README for
   root paths. Prepare preserves existing files.
2. Configure ADC or Workload Identity Federation, backend authentication and
   optional impersonation. Platform requires private cluster reachability and
   `gke-gcloud-auth-plugin`; these are independent of provider authentication.
3. Bootstrap in an existing administrative project:

```powershell
python scripts/deploy.py preflight --layer bootstrap
python scripts/deploy.py init --layer bootstrap
python scripts/deploy.py plan --layer bootstrap
terraform -chdir=landing-zone/bootstrap show review.tfplan
```

Execute a reviewed plan only through an explicit
`python scripts/deploy.py apply --layer bootstrap`. Saved-plan apply executes
immediately. After the bucket exists, copy `landing-zone/bootstrap/backend.tf.example`
to `backend.tf` in the same directory, fill its `backend.hcl`, and migrate state:

```powershell
terraform -chdir=landing-zone/bootstrap init -migrate-state -backend-config=backend.hcl
```

4. Deploy foundation, obtain the network handoff, then GKE and platform. Run the
   network layer only with the network owner's agreement. For each layer:

```powershell
python scripts/deploy.py preflight --layer gke
python scripts/deploy.py init --layer gke
python scripts/deploy.py plan --layer gke
terraform -chdir=workloads/prod/gke show review.tfplan
# Execute only the reviewed saved plan:
python scripts/deploy.py apply --layer gke
```

The helper always passes common.tfvars explicitly. Each root automatically loads
its own terraform.tfvars. Use unique state prefixes, the default CLI workspace and
separate roots/prefixes for additional environments. Never apply all roots recursively.

5. Configure optional layers only after their prerequisites are reviewed:
   VPN peer settings/secrets and AWS coordination; approved selective voice VM
   inventory/images/draining; DNS/certificates; later SQL/Redis PSA and migration.
   Supply VPN shared secrets externally. State and saved plans may contain secrets.
6. Supply application manifests, private Git access, Argo CD Applications,
   workload identity annotations, Gateway routes, network policies and tested
   scaling/draining. Infrastructure provisioning does not migrate applications.

Before any live plan, verify IAM, resource imports/ownership, approved capacities,
network non-overlap and private access. The preflight helper catches common mock
markers; it is not a cloud permission, HCL or IP-overlap audit. No real plan/apply
has been performed as part of repository alignment.
