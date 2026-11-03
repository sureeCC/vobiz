module "project_services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "18.4.0"

  project_id                  = local.target_project_id
  activate_apis               = var.enabled_apis
  disable_services_on_destroy = false
  disable_dependent_services  = false
}
