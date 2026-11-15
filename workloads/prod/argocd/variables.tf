variable "project_id" {
  type        = string
  description = "Existing GCP project ID; placeholder values are rejected."
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Use an existing GCP project ID: 6-30 lowercase letters, digits or hyphens."
  }
}
variable "region" {
  type    = string
  default = "asia-south1"
}

variable "cluster_name" {
  type = string
}
variable "cluster_location" {
  type        = string
  description = "Region for regional GKE, zone for zonal GKE."
}
variable "namespace" {
  type    = string
  default = "argocd"
}
variable "chart_version" {
  type    = string
  default = "10.18.0"
}
variable "values" {
  type    = list(string)
  default = []
  validation {
    condition     = alltrue([for value in var.values : can(keys(yamldecode(value)))])
    error_message = "Each Helm values entry must be a valid YAML mapping."
  }
}
