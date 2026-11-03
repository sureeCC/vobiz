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
