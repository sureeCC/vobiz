# Retain these mappings for existing deployments using the original addresses.
moved {
  from = module.vpc
  to   = module.networking.module.vpc
}

moved {
  from = module.cloud_router
  to   = module.networking.module.cloud_router
}
