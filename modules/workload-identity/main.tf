resource "google_service_account" "workload" {
  for_each     = var.accounts
  project      = var.project_id
  account_id   = each.key
  display_name = each.value.display_name
}
resource "google_service_account_iam_member" "workload_identity" {
  for_each           = var.accounts
  service_account_id = google_service_account.workload[each.key].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.workload_pool_project_id}.svc.id.goog[${each.value.namespace}/${each.value.kubernetes_service_account}]"
}
locals {
  grants = flatten([for name, account in var.accounts : [for role in account.project_roles : { account = name, role = role
  }]])
}
resource "google_project_iam_member" "role" {
  for_each = { for grant in local.grants : "${grant.account}/${grant.role}" => grant
  }
  project = var.project_id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.workload[each.value.account].email}"
}
