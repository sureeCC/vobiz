resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name   = var.argocd_namespace
    labels = { "app.kubernetes.io/part-of" = "argocd" }
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = kubernetes_namespace_v1.argocd.metadata[0].name
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_chart_version
  create_namespace = false
  atomic           = true
  cleanup_on_fail  = true
  wait             = true
  timeout          = 900
  values           = [file("${path.module}/${var.argocd_values_file}")]
}
