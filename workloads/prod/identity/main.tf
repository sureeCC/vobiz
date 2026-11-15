module "identity" {
  source                   = "../../../modules/workload-identity"
  project_id               = var.project_id
  accounts                 = var.accounts
  workload_pool_project_id = var.workload_pool_project_id
  depends_on               = [google_project_service.required]
}
