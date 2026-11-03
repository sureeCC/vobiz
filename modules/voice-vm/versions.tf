terraform {
  required_version = ">= 1.16.6, < 1.17.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.46.1"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "7.46.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.9.1"
    }
  }
}
