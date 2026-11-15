provider "google" {
  project = var.project_id
  region  = var.region
}
provider "helm" {
  kubernetes = {
    host                   = "https://${data.google_container_cluster.existing.endpoint}"
    cluster_ca_certificate = base64decode(data.google_container_cluster.existing.master_auth[0].cluster_ca_certificate)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "gke-gcloud-auth-plugin"
      args        = ["--use_application_default_credentials"]

    }

  }
}
data "google_container_cluster" "existing" {
  project  = var.project_id
  name     = var.cluster_name
  location = var.cluster_location
}
