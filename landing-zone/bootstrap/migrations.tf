moved {
  from = module.terraform_state
  to   = module.state_bucket.module.terraform_state
}
moved {
  from = google_storage_bucket_iam_member.state_admin
  to   = module.state_bucket.google_storage_bucket_iam_member.state_admin
}
