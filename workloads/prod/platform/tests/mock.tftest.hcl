# Offline tests: every provider is mocked. No GCP reads/writes occur.
mock_provider "google" {
  mock_data "google_compute_network" {
    defaults = {
      name      = "vobiz-prod-vpc"
      self_link = "https://www.googleapis.com/compute/v1/projects/mock-vobiz-project/global/networks/vobiz-prod-vpc"
    }
  }
  mock_data "google_compute_subnetwork" {
    defaults = {
      name      = "vobiz-prod-as1-subnet-gke"
      self_link = "https://www.googleapis.com/compute/v1/projects/mock-vobiz-project/regions/asia-south1/subnetworks/vobiz-prod-as1-subnet-gke"
    }
  }
  mock_data "google_compute_global_address" {
    defaults = { name = "vobiz-prod-private-services" }
  }
  mock_data "google_container_cluster" {
    defaults = {
      endpoint    = "192.0.2.1"
      master_auth = [{ cluster_ca_certificate = "bW9jay1jZXJ0aWZpY2F0ZQ==" }]
    }
  }
  mock_data "google_container_engine_versions" {
    defaults = {
      latest_master_version = "1.34.1-gke.1000000"
      valid_master_versions = ["1.34.1-gke.1000000"]
      valid_node_versions   = ["1.34.1-gke.1000000"]
      release_channel_default_version = {
        REGULAR = "1.34.1-gke.1000000"
        STABLE  = "1.34.1-gke.1000000"
        RAPID   = "1.34.1-gke.1000000"
      }
    }
  }
}
mock_provider "google-beta" {}
mock_provider "random" {}
mock_provider "kubernetes" {}
mock_provider "helm" {}
run "mock_example_plan" {
  command = plan
  variables {
    project_id = "mock-vobiz-project"
  }
}

run "workload_identity_grants" {
  command = plan
  variables {
    project_id = "mock-vobiz-project"
    workload_project_grants = {
      metrics = { role = "roles/monitoring.metricWriter", member = "serviceAccount:metrics@mock-vobiz-project.iam.gserviceaccount.com" }
    }
    workload_identity_links = {
      metrics = {
        service_account_id         = "projects/mock-vobiz-project/serviceAccounts/metrics@mock-vobiz-project.iam.gserviceaccount.com"
        namespace                  = "observability"
        kubernetes_service_account = "metrics"
      }
    }
  }
  assert {
    condition     = google_service_account_iam_member.workloads["metrics"].member == "serviceAccount:mock-vobiz-project.svc.id.goog[observability/metrics]"
    error_message = "The binding must target the configured KSA, not all workloads."
  }
}
