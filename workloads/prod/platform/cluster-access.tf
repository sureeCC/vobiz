# Run this root only after GKE exists, from a runner with private endpoint access.
data "google_container_cluster" "production" {
  project  = var.project_id
  name     = var.cluster_name
  location = var.region
}

# ADC/WIF credentials support automatic token refresh via the gcloud plugin.
# If using impersonation, separately configure impersonated ADC for the plugin;
# the google provider's impersonate_service_account does not configure this plugin.
provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.production.endpoint}"
  cluster_ca_certificate = base64decode(data.google_container_cluster.production.master_auth[0].cluster_ca_certificate)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "gke-gcloud-auth-plugin"
    args        = ["--use_application_default_credentials"]
  }
}

provider "helm" {
  kubernetes = {
    host                   = "https://${data.google_container_cluster.production.endpoint}"
    cluster_ca_certificate = base64decode(data.google_container_cluster.production.master_auth[0].cluster_ca_certificate)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "gke-gcloud-auth-plugin"
      args        = ["--use_application_default_credentials"]
    }
  }
}
