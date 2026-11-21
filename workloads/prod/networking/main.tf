module "vpc" {
  source = "../../../modules/networking/vnet"

  project_id                             = var.project_id
  network_name                           = var.network_name
  routing_mode                           = var.routing_mode
  subnets                                = var.subnets
  secondary_ranges                       = var.secondary_ranges
  routes                                 = var.routes
  ingress_rules                          = var.ingress_rules
  egress_rules                           = var.egress_rules
  delete_default_internet_gateway_routes = var.delete_default_internet_gateway_routes
  private_service_access_config          = var.private_service_access_config
  description                            = var.vnet_description
}

module "cloud_router" {
  source     = "../../../modules/networking/cloud-router"
  depends_on = [module.vpc]

  name        = var.router_name
  region      = var.region
  project_id  = var.project_id
  network     = module.vpc.network_id
  description = var.router_description
  nats        = var.nats
}
