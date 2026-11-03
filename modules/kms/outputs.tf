output "keys" {
  value = try(module.kms[0].keys, {})
}
output "keyring" {
  value = try(module.kms[0].keyring, null)
}
output "keyring_count" {
  value = length(module.kms)
}
