module "voice_vm" {
  source               = "../../../modules/voice-vm"
  instances            = var.instances
  labels               = var.labels
  project_id           = var.project_id
  region               = var.region
  service_account_name = var.service_account_name
  subnetwork_name      = var.subnetwork_name
}
