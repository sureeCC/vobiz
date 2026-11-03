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
