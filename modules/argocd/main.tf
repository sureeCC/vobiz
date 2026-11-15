resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = var.namespace
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.chart_version
  atomic           = true
  cleanup_on_fail  = true
  wait             = true
  timeout          = 900
  max_history      = 5
  values = concat([yamlencode({
    server = { service = { type = "ClusterIP"
      }
    }
    configs = { params = { "server.insecure" = false
      }
    }

  })], var.values)
}
