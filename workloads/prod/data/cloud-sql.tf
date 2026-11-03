module "cloud_sql" {
  source                      = "../../../modules/cloud-sql"
  enable_sql                  = var.enable_sql
  labels                      = var.labels
  private_network_self_link   = try(data.google_compute_network.production[0].self_link, null)
  private_services_range_name = try(data.google_compute_global_address.private_services[0].name, var.private_services_range_name)
  project_id                  = var.project_id
  region                      = var.region
  sql                         = var.sql
  depends_on                  = [module.project_services]
}
