output "project_id" {
  description = "Production project ID."
  value       = local.target_project_id
}
output "service_account_emails" {
  description = "Created account IDs mapped to their emails."
  value       = { for name, account in module.service_accounts : name => account.email }
}
