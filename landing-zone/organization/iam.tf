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
