module "https_load_balancer" {
  source                    = "../../../modules/https-load-balancer"
  armor_policy_name         = var.armor_policy_name
  enable_http_load_balancer = var.enable_http_load_balancer
  http_address_name         = var.http_address_name
  http_backends             = var.http_backends
  http_domains              = var.http_domains
  http_load_balancer_name   = var.http_load_balancer_name
  project_id                = var.project_id
}
