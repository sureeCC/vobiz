resource "google_compute_global_address" "https" {
  count   = var.enable_http_load_balancer ? 1 : 0
  project = var.project_id
  name    = var.http_address_name
}

resource "google_compute_address" "voice" {
  for_each     = var.voice_address_names
  project      = var.project_id
  region       = var.region
  name         = each.value
  address_type = "EXTERNAL"
}
