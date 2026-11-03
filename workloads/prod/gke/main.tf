module "gke" {
  source                      = "../../../modules/gke"
  providers                   = { google = google, google-beta = google-beta }
  node_pools                  = var.node_pools
  cluster_name                = var.cluster_name
  network_name                = var.network_name
  subnetwork_name             = var.subnetwork_name
  pod_range_name              = var.pod_range_name
  service_range_name          = var.service_range_name
  zones                       = var.zones
  node_service_account_name   = var.node_service_account_name
  control_plane_cidr          = var.control_plane_cidr
  enable_private_endpoint     = var.enable_private_endpoint
  master_authorized_networks  = var.master_authorized_networks
  release_channel             = var.release_channel
  maintenance_start_time      = var.maintenance_start_time
  project_id                  = var.project_id
  region                      = var.region
  environment                 = var.environment
  labels                      = var.labels
  impersonate_service_account = var.impersonate_service_account
}
