module "node_identity" {
  source  = "terraform-google-modules/service-accounts/google"
  version = "5.1.0"

  project_id    = var.project_id
  names         = [var.node_service_account_name]
  display_name  = "Vobiz GKE node identity"
  project_roles = ["${var.project_id}=>roles/container.defaultNodeServiceAccount"]
  generate_keys = false
}
