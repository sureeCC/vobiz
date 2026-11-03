module "buckets" {
  for_each = var.buckets
  source   = "terraform-google-modules/cloud-storage/google"
  version  = "12.4.1"

  project_id               = var.project_id
  names                    = [each.key]
  location                 = var.region
  storage_class            = each.value.storage_class
  public_access_prevention = "enforced"
  bucket_policy_only       = { (each.key) = true }
  versioning               = { (each.key) = each.value.versioning }
  force_destroy            = { (each.key) = false }
  labels                   = var.labels
}
