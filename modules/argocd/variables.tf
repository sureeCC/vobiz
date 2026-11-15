variable "namespace" {
  type    = string
  default = "argocd"
}
variable "chart_version" {
  type    = string
  default = "10.18.0"
}
variable "values" {
  type        = list(string)
  default     = []
  description = "Additional YAML values. Do not put credentials in these values: Helm stores them in Terraform state."
}
