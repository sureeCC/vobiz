output "connection_name" {
  value = try(module.postgresql[0].instance_connection_name, null)
}
output "instance_count" {
  value = length(module.postgresql)
}
