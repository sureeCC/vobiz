output "members" {
  value = { for name, binding in google_service_account_iam_member.workloads : name => binding.member }
}
