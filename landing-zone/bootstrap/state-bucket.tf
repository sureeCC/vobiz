module "state_bucket" {
  source              = "../../modules/state-bucket"
  project_id          = var.project_id
  region              = var.region
  state_admin_members = var.state_admin_members
  state_bucket_name   = var.state_bucket_name
}
