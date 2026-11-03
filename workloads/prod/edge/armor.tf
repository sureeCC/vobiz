resource "google_compute_security_policy" "http" {
  count       = var.enable_http_load_balancer ? 1 : 0
  project     = var.project_id
  name        = var.armor_policy_name
  description = "Baseline HTTP policy; extend after reviewing existing WAF behavior."
  rule {
    action      = "deny(403)"
    priority    = 1000
    description = "Block public metrics endpoints"
    match {
      expr { expression = "request.path == '/metrics' || request.path.startsWith('/metrics/')" }
    }
  }
  rule {
    action   = "allow"
    priority = 2147483647
    match {
      versioned_expr = "SRC_IPS_V1"
      config { src_ip_ranges = ["*"] }
    }
  }
}
