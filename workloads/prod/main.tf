module "vpc" {
  source = "../../modules/networking/vnet"

  project_id       = var.project_id
  network_name     = var.network_name
  routing_mode     = var.routing_mode
  subnets          = var.subnets
  secondary_ranges = var.secondary_ranges
  routes           = var.routes
  description      = var.vnet_description
}

module "cloud_router" {
  source     = "../../modules/networking/cloud-router"
  depends_on = [module.vpc]

  name        = var.router_name
  region      = var.region
  project_id  = var.project_id
  network     = var.network
  description = var.router_description
  nats        = var.nats
}
