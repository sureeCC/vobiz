terraform {
  required_version = ">= 1.7"
  required_providers {
    google = { source = "hashicorp/google", version = "8.9.0"
    }
    helm = { source = "hashicorp/helm", version = "3.3.0"
    }

  }
}
