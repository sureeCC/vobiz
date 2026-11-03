output "state_bucket_name" {
  description = "Use in the backend.hcl files of deployment layers."
  value       = module.terraform_state.name
}
