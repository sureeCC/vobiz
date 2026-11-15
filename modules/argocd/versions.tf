terraform {
  required_version = ">= 1.7"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.3, < 4.0"
    }
  }
}
