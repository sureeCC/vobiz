# Existing project by default. Creation is an explicit configuration choice.
module "project" {
  count   = var.create_project ? 1 : 0
  source  = "terraform-google-modules/project-factory/google"
  version = "18.4.0"

  name                        = var.project_name
  project_id                  = var.project_id
  org_id                      = var.organization_id
  folder_id                   = var.folder_id
  billing_account             = var.billing_account_id
  random_project_id           = false
  deletion_policy             = "PREVENT"
  create_project_sa           = false
  default_service_account     = "disable"
  activate_apis               = []
  disable_services_on_destroy = false
}

locals {
  target_project_id = var.create_project ? module.project[0].project_id : var.project_id
}
