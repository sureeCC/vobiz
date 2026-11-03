output "project_id" {
  value = local.target_project_id
}
output "service_account_emails" {
  value = { for name, account in module.service_accounts : name => account.email }
}
