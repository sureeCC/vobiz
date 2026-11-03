module "cloud_storage" {
  source     = "../../../modules/cloud-storage"
  buckets    = var.buckets
  labels     = var.labels
  project_id = var.project_id
  region     = var.region
}
