output "sql_connection_name" {
  description = "Cloud SQL connection name, or null when disabled."
  value       = try(module.postgresql[0].instance_connection_name, null)
}
output "cache_host" {
  description = "Private Redis endpoint, or null when disabled. No auth string is exported."
  value       = try(module.redis[0].host, null)
}
output "storage_buckets" {
  description = "Created bucket names."
  value       = { for name, bucket in module.buckets : name => bucket.name }
}
