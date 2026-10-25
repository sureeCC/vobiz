terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 8.8"
    }
  }
}

provider "google" {
  project = "vobiz-analytics"
  region  = "asia-south1"
}
