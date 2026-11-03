output "buckets" {
  value = { for name, bucket in module.buckets : name => bucket.name }
}
output "bucket_count" {
  value = length(module.buckets)
}
