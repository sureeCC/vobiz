moved {
  from = module.project
  to   = module.project_foundation.module.project
}
moved {
  from = module.project_services
  to   = module.project_foundation.module.project_services
}
moved {
  from = google_project_iam_audit_config.data_access
  to   = module.project_foundation.google_project_iam_audit_config.data_access
}
moved {
  from = google_project_iam_member.project_access
  to   = module.project_foundation.google_project_iam_member.project_access
}
moved {
  from = module.service_accounts
  to   = module.project_foundation.module.service_accounts
}
moved {
  from = google_org_policy_policy.boolean
  to   = module.project_foundation.google_org_policy_policy.boolean
}
