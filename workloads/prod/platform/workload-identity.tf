module "workload_identity" {
  source                  = "../../../modules/workload-identity"
  project_id              = var.project_id
  workload_identity_links = var.workload_identity_links
  workload_project_grants = var.workload_project_grants
}
