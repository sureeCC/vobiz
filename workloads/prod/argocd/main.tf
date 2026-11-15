module "argocd" {
  source        = "../../../modules/argocd"
  namespace     = var.namespace
  chart_version = var.chart_version
  values        = var.values
  depends_on    = [google_project_service.required]
}
