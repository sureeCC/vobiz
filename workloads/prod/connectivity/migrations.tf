moved {
  from = data.google_compute_network.production
  to   = module.ha_vpn.data.google_compute_network.production
}
moved {
  from = module.aws_vpn
  to   = module.ha_vpn.module.aws_vpn
}
