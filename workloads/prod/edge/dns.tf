module "cloud_dns" {
  source     = "../../../modules/dns"
  dns_zones  = var.dns_zones
  project_id = var.project_id
}
