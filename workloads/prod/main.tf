module "vpc" {
  source = "../../modules/networking/vnet"

  project_id                             = var.project_id
  network_name                           = var.network_name
  routing_mode                           = var.routing_mode
  subnets                                = var.subnets
  secondary_ranges                       = var.secondary_ranges
  routes                                 = var.routes
  description                            = var.vnet_description
  ingress_rules                          = var.ingress_rules
  egress_rules                           = var.egress_rules
  private_service_access_config          = var.private_service_access_config
  delete_default_internet_gateway_routes = var.delete_default_internet_gateway_routes
}

module "cloud_router" {
  source = "../../modules/networking/cloud-router"
  count  = var.create_router ? 1 : 0

  name        = var.router_name
  region      = var.region
  project_id  = var.project_id
  network     = module.vpc.network_id
  description = var.router_description
  nats        = var.nats
}

# Preserve the router module address when introducing the optional-create switch.
moved {
  from = module.cloud_router
  to   = module.cloud_router[0]
}
