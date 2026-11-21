output "id" { value = google_redis_instance.cache.id }
output "host" { value = google_redis_instance.cache.host }
output "port" { value = google_redis_instance.cache.port }
output "server_ca_certs" { value = google_redis_instance.cache.server_ca_certs }
# Redis AUTH is deliberately not exposed as an output.
