moved {
  from = module.data_apis
  to   = module.project_services.module.services
}
moved {
  from = module.postgresql
  to   = module.cloud_sql.module.postgresql
}
moved {
  from = module.redis
  to   = module.redis_service.module.redis
}
moved {
  from = module.buckets
  to   = module.cloud_storage.module.buckets
}
