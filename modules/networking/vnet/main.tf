module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 18.3"

  project_id       = var.project_id
  network_name     = var.network_name
  routing_mode     = var.routing_mode
  subnets          = var.subnets
  secondary_ranges = var.secondary_ranges
  routes           = var.routes
  description      = var.description
}
