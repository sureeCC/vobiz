module "networking" {
  source     = "./networking"
  depends_on = [google_project_service.platform]

  project_id                             = var.project_id
  region                                 = var.region
  network_name                           = var.network_name
  routing_mode                           = var.routing_mode
  subnets                                = var.subnets
  secondary_ranges                       = var.secondary_ranges
  routes                                 = var.routes
  egress_rules                           = var.egress_rules
  ingress_rules                          = var.ingress_rules
  private_service_access_config          = var.private_service_access_config
  delete_default_internet_gateway_routes = var.delete_default_internet_gateway_routes
  vnet_description                       = var.vnet_description
  router_name                            = var.router_name
  create_router                          = var.create_router
  log_config_enable                      = var.log_config_enable
  log_config_filter                      = var.log_config_filter
  router_description                     = var.router_description
  nats                                   = var.nats
  network                                = var.network
}
