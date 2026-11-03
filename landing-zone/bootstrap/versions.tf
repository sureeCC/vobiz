terraform {
  required_version = ">= 1.16.6, < 1.17.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.46.1"
    }
  }
}
