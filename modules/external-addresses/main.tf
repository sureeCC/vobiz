resource "google_compute_address" "voice" {
  for_each     = var.voice_address_names
  project      = var.project_id
  region       = var.region
  name         = each.value
  address_type = "EXTERNAL"
}
