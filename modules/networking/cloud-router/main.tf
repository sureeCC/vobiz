module "cloud_router" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "9.1.0"

  name   = var.name
  region = var.region

  project_id  = var.project_id
  network     = var.network
  description = var.description
  nats        = var.nats
}
