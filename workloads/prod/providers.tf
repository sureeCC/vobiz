terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 8.8"
    }
  }
}

provider "google" {
  project = "gcp-voice-infra"
  region  = "asia-south1"
  #  impersonate_service_account = "terraform-infra@gcp-voice-infra.iam.gserviceaccount.com"
}
