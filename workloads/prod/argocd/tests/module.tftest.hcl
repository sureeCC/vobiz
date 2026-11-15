mock_provider "helm" {}
run "module_contract" {
  command = plan
  module {
    source = "../../../modules/argocd"
  }
  variables {
    namespace = "argocd"
  }
  assert {
    condition     = helm_release.argocd.atomic && helm_release.argocd.wait && helm_release.argocd.create_namespace && helm_release.argocd.version == "10.18.0"
    error_message = "The module must preserve its access, security and lifecycle contract."
  }
}
