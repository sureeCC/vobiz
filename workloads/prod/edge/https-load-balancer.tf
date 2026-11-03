# Optional Terraform-owned LB for an explicitly approved backend design.
# Keep disabled when a GKE Gateway/Ingress controller owns the application's LB.
# This is HTTP(S) only; do not route SIP/RTP through this component.
module "https" {
  count   = var.enable_http_load_balancer ? 1 : 0
  source  = "GoogleCloudPlatform/lb-http/google"
  version = "14.3.0"

  project                         = var.project_id
  name                            = var.http_load_balancer_name
  create_address                  = false
  address                         = google_compute_global_address.https[0].address
  ssl                             = true
  https_redirect                  = true
  managed_ssl_certificate_domains = var.http_domains
  security_policy                 = google_compute_security_policy.http[0].self_link
  firewall_networks               = [] # Network state owns reviewed health-check rules.
  backends = { for name, backend in var.http_backends : name => {
    protocol    = "HTTP"
    enable_cdn  = false
    port        = backend.port
    port_name   = backend.port_name
    timeout_sec = backend.timeout_seconds
    health_check = {
      protocol     = "HTTP"
      port         = backend.port
      request_path = backend.health_check_path
      logging      = true
    }
    log_config = { enable = true, sample_rate = 1.0 }
    groups = [for group in backend.instance_group_self_links : {
      group = group
    }]
  } }
  # This optional baseline supports a single default backend. Production host/path
  # routing remains an application/Gateway deliverable, not an inferred mapping.
}
