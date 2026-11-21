output "registry_repository_ids" { value = module.registry.repository_ids }
output "registry_docker_urls" { value = module.registry.docker_urls }
output "secrets_secret_ids" { value = module.secrets.secret_ids }
output "cache_id" { value = var.cache == null ? null : module.cache[0].id }
output "cache_host" { value = var.cache == null ? null : module.cache[0].host }
output "cache_port" { value = var.cache == null ? null : module.cache[0].port }
output "cache_server_ca_certs" { value = var.cache == null ? null : module.cache[0].server_ca_certs }
