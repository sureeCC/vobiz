variable "argocd_chart_version" {
  description = "Pinned Argo CD chart release."
  type        = string
}

variable "argocd_namespace" {
  description = "Namespace owned by this Terraform bootstrap."
  type        = string
}

variable "values_yaml" {
  description = "Argo CD Helm values supplied by the deployment root."
  type        = string
}
