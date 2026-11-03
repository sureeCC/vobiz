output "host" {
  value = try(module.redis[0].host, null)
}
output "instance_count" {
  value = length(module.redis)
}
