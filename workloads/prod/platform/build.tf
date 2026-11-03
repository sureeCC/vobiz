module "cloud_build" {
  source         = "../../../modules/cloud-build"
  build_triggers = var.build_triggers
  project_id     = var.project_id
  region         = var.region
}
