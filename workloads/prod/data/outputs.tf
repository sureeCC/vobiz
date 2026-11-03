output "sql_connection_name" {
  value = module.cloud_sql.connection_name
}
output "cache_host" {
  value = module.redis_service.host
}
output "storage_buckets" {
  value = module.cloud_storage.buckets
}
