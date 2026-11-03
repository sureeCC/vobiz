module "project_services" {
  source     = "../../../modules/project-services"
  project_id = var.project_id
  activate_apis = concat(
    var.enable_sql ? ["sqladmin.googleapis.com"] : [],
    var.enable_cache ? ["redis.googleapis.com"] : []
  )
}
