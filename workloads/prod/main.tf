module "networking" {
  source     = "./networking"
  depends_on = [google_project_service.platform]

  project_id                             = var.project_id
  region                                 = var.region
  network_name                           = module.naming.names["vpc"]
  routing_mode                           = var.routing_mode
  subnets                                = local.named_subnets
  secondary_ranges                       = local.named_ranges
  routes                                 = [for route in var.routes : merge(route, { name = module.naming.names["route/${route.name}"] })]
  egress_rules                           = [for rule in var.egress_rules : merge(rule, { name = module.naming.names["egress/${rule.name}"] })]
  ingress_rules                          = [for rule in var.ingress_rules : merge(rule, { name = module.naming.names["ingress/${rule.name}"] })]
  private_service_access_config          = local.named_psa
  delete_default_internet_gateway_routes = var.delete_default_internet_gateway_routes
  vnet_description                       = var.vnet_description
  router_name                            = module.naming.names["router"]
  create_router                          = var.create_router
  log_config_enable                      = var.log_config_enable
  log_config_filter                      = var.log_config_filter
  router_description                     = var.router_description
  nats                                   = local.named_nats
  network                                = var.network
}
