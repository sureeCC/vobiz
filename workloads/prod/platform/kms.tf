module "encryption_keys" {
  source           = "../../../modules/kms"
  kms_key_names    = var.kms_key_names
  kms_keyring_name = var.kms_keyring_name
  labels           = var.labels
  project_id       = var.project_id
  region           = var.region
}
