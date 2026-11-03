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

module "project_services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "18.4.0"

  project_id                  = local.target_project_id
  activate_apis               = var.enabled_apis
  disable_services_on_destroy = false
  disable_dependent_services  = false
}

# Authoritative for the listed service's audit configuration. Reconcile any
# existing exemption rules before applying; this does not alter IAM bindings.
resource "google_project_iam_audit_config" "data_access" {
  for_each = var.audit_services
  project  = local.target_project_id
  service  = each.value

  audit_log_config {
    log_type = "DATA_READ"
  }
  audit_log_config {
    log_type = "DATA_WRITE"
  }
}

# Additive grants: existing project IAM members remain under their current owners.
resource "google_project_iam_member" "project_access" {
  for_each   = var.project_iam_members
  project    = local.target_project_id
  role       = each.value.role
  member     = each.value.member
  depends_on = [module.project_services]
}

module "service_accounts" {
  for_each = var.service_accounts
  source   = "terraform-google-modules/service-accounts/google"
  version  = "5.1.0"

  project_id    = local.target_project_id
  names         = [each.key]
  display_name  = each.value.display_name
  description   = each.value.description
  project_roles = [for role in each.value.roles : "${local.target_project_id}=>${role}"]
  generate_keys = false
  depends_on    = [module.project_services]
}

# No policies are imposed by default. Policies apply at project level only;
# organisation/folder policy changes need a separately agreed ownership scope.
resource "google_org_policy_policy" "boolean" {
  for_each = var.project_boolean_policies
  name     = "projects/${local.target_project_id}/policies/${each.key}"
  parent   = "projects/${local.target_project_id}"
  spec {
    rules {
      enforce = each.value ? "TRUE" : "FALSE"
    }
  }
  depends_on = [module.project_services]
}
