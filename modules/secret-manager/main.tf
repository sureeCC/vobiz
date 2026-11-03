# Create secret containers only. Populate versions through an approved secret
# delivery workflow so plaintext application credentials are not Terraform inputs.
module "secrets" {
  source  = "GoogleCloudPlatform/secret-manager/google"
  version = "0.10.0"

  project_id = var.project_id
  secrets = [for name in var.secret_names : {
    name           = name
    create_version = false
  }]
  labels = { for name in var.secret_names : name => var.labels }
}

resource "google_secret_manager_secret_iam_member" "accessors" {
  for_each   = var.secret_accessors
  project    = var.project_id
  secret_id  = each.value.secret_name
  role       = "roles/secretmanager.secretAccessor"
  member     = each.value.member
  depends_on = [module.secrets]
}
