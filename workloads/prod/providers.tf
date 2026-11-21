terraform {
  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 8.8"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 8.8"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  #  impersonate_service_account = "terraform-infra@gcp-voice-infra.iam.gserviceaccount.com"
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}
