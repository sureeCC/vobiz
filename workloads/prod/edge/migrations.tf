moved {
  from = module.https
  to   = module.https_load_balancer.module.https
}
moved {
  from = google_compute_global_address.https
  to   = module.https_load_balancer.google_compute_global_address.https
}
moved {
  from = google_compute_security_policy.http
  to   = module.https_load_balancer.google_compute_security_policy.http
}
moved {
  from = module.dns
  to   = module.cloud_dns.module.dns
}
moved {
  from = google_compute_address.voice
  to   = module.external_addresses.google_compute_address.voice
}
