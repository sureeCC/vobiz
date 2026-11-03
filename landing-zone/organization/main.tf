module "project_foundation" {
  source                   = "../../modules/project"
  audit_services           = var.audit_services
  billing_account_id       = var.billing_account_id
  create_project           = var.create_project
  enabled_apis             = var.enabled_apis
  folder_id                = var.folder_id
  organization_id          = var.organization_id
  project_boolean_policies = var.project_boolean_policies
  project_iam_members      = var.project_iam_members
  project_id               = var.project_id
  project_name             = var.project_name
  service_accounts         = var.service_accounts
}
