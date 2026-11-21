terraform {
  backend "gcs" {
    bucket = "vobiz-terraform"
    prefix = "terraform-state/prod"
  }
}
