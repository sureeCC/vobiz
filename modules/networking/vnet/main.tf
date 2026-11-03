module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "18.3.1"

  project_id                             = var.project_id
  network_name                           = var.network_name
  routing_mode                           = var.routing_mode
  subnets                                = var.subnets
  secondary_ranges                       = var.secondary_ranges
  routes                                 = var.routes
  description                            = var.description
  ingress_rules                          = var.ingress_rules
  egress_rules                           = var.egress_rules
  private_service_access_config          = var.private_service_access_config
  delete_default_internet_gateway_routes = var.delete_default_internet_gateway_routes
}
