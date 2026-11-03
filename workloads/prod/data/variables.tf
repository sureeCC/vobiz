variable "enable_sql" {
  description = "False while databases remain on AWS."
  type        = bool
  default     = false
}
variable "enable_cache" {
  description = "False until source cache compatibility and migration scope are confirmed."
  type        = bool
  default     = false
}
variable "network_name" {
  description = "Existing VPC name."
  type        = string
}
variable "private_services_range_name" {
  description = "Existing PSA range owned and connected by network state. Apply network first."
  type        = string
}
variable "sql" {
  description = "Mock PostgreSQL configuration; requires source compatibility, sizing and IAM user setup before use."
  type = object({
    name              = string
    database_version  = string
    tier              = string
    replica_tier      = string
    replica_zone      = string
    disk_size_gb      = number
    backup_start_time = string
    retained_backups  = number
  })
}
variable "cache" {
  description = "Mock Redis target; validate actual source engine/features before enabling."
  type        = object({ name = string, memory_size_gb = number, redis_version = string })
}
variable "buckets" {
  description = "Explicitly approved application bucket names and storage settings. Empty initially."
  type        = map(object({ storage_class = string, versioning = bool }))
  default     = {}
}
