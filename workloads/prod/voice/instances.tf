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
