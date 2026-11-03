# The administrative project and caller permissions must already exist.
# Start with local state, then migrate this root into the created bucket.
module "terraform_state" {
  source  = "terraform-google-modules/cloud-storage/google"
  version = "12.4.1"

  project_id               = var.project_id
  names                    = [var.state_bucket_name]
  location                 = var.region
  public_access_prevention = "enforced"
  bucket_policy_only       = { (var.state_bucket_name) = true }
  versioning               = { (var.state_bucket_name) = true }
  force_destroy            = { (var.state_bucket_name) = false }
  labels                   = { managed_by = "terraform", purpose = "terraform-state" }
}

resource "google_storage_bucket_iam_member" "state_admin" {
  for_each = var.state_admin_members
  bucket   = module.terraform_state.name
  role     = "roles/storage.objectAdmin"
  member   = each.value
}
