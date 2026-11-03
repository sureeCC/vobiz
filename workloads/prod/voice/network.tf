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
