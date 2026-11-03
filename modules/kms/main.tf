module "kms" {
  count   = length(var.kms_key_names) > 0 ? 1 : 0
  source  = "terraform-google-modules/kms/google"
  version = "4.2.1"

  project_id          = var.project_id
  location            = var.region
  keyring             = var.kms_keyring_name
  keys                = var.kms_key_names
  prevent_destroy     = true
  key_rotation_period = "7776000s"
  labels              = var.labels
}

