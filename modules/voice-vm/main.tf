module "instances" {
  for_each = var.instances
  source   = "terraform-google-modules/vm/google//modules/compute_instance"
  version  = "15.4.1"

  project_id          = var.project_id
  region              = var.region
  zone                = each.value.zone
  hostname            = each.key
  add_hostname_suffix = false
  num_instances       = 1
  instance_template   = module.templates[each.key].self_link
  subnetwork          = data.google_compute_subnetwork.voice[0].self_link
  subnetwork_project  = var.project_id
  deletion_protection = true
  access_config = each.value.assign_public_ip ? [{
    nat_ip       = google_compute_address.voice[each.key].address
    network_tier = "PREMIUM"
  }] : []
}

module "templates" {
  for_each = var.instances
  source   = "terraform-google-modules/vm/google//modules/instance_template"
  version  = "15.4.1"

  project_id             = var.project_id
  region                 = var.region
  name_prefix            = "${each.key}-template"
  machine_type           = each.value.machine_type
  source_image           = each.value.source_image
  disk_size_gb           = tostring(each.value.disk_size_gb)
  disk_type              = "pd-balanced"
  subnetwork             = data.google_compute_subnetwork.voice[0].self_link
  subnetwork_project     = var.project_id
  create_service_account = false
  # A deterministic email avoids an upstream module for_each depending on an
  # apply-time service-account output. depends_on still orders account creation.
  service_account    = { email = "${var.service_account_name}@${var.project_id}.iam.gserviceaccount.com", scopes = ["cloud-platform"] }
  enable_shielded_vm = true
  metadata           = { enable-oslogin = "TRUE", block-project-ssh-keys = "TRUE" }
  tags               = each.value.network_tags
  labels             = merge(var.labels, { workload = "voice" })
  access_config      = []
  depends_on         = [module.voice_identity]
}

module "voice_identity" {
  count        = length(var.instances) > 0 ? 1 : 0
  source       = "terraform-google-modules/service-accounts/google"
  version      = "5.1.0"
  project_id   = var.project_id
  names        = [var.service_account_name]
  display_name = "Vobiz voice VM identity"
  project_roles = [
    "${var.project_id}=>roles/logging.logWriter",
    "${var.project_id}=>roles/monitoring.metricWriter"
  ]
  generate_keys = false
}

data "google_compute_subnetwork" "voice" {
  count   = length(var.instances) > 0 ? 1 : 0
  project = var.project_id
  region  = var.region
  name    = var.subnetwork_name
}

resource "google_compute_address" "voice" {
  for_each     = { for name, instance in var.instances : name => instance if instance.assign_public_ip }
  project      = var.project_id
  region       = var.region
  name         = "${each.key}-ip"
  address_type = "EXTERNAL"
}
