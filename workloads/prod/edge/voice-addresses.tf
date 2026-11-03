module "external_addresses" {
  source              = "../../../modules/external-addresses"
  project_id          = var.project_id
  region              = var.region
  voice_address_names = var.voice_address_names
}
