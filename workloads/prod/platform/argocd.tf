module "argocd" {
  source               = "../../../modules/argocd"
  argocd_chart_version = var.argocd_chart_version
  argocd_namespace     = var.argocd_namespace
  values_yaml          = file("${path.module}/${var.argocd_values_file}")
}
