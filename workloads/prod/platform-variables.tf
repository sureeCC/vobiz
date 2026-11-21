variable "repositories" {
  type = map(object({
    description    = optional(string, "Vobiz Docker images")
    readers        = optional(set(string), [])
    writers        = optional(set(string), [])
    immutable_tags = optional(bool, true)
  }))
  default     = {}
  description = "Logical Docker repository keys and repository-scoped IAM members. Physical IDs are generated."
}
variable "secrets" {
  type = map(object({
    accessors             = optional(set(string), [])
    replication_locations = optional(set(string), [])
  }))
  default     = {}
  description = "Logical secret keys and accessor IAM members. Physical IDs are generated. Empty locations uses automatic replication. Values are populated outside Terraform."
}
variable "cache" {
  type = object({
    name                 = optional(string)
    memory_size_gb       = optional(number, 5)
    tier                 = optional(string, "STANDARD_HA")
    redis_version        = optional(string, "REDIS_7_2")
    maintenance_day      = optional(string, "SUNDAY")
    maintenance_hour_utc = optional(number, 3)
  })
  default     = null
  description = "Private Redis configuration; null omits Redis."
  validation {
    condition     = var.cache == null || var.private_service_access_config.enable_private_services_connection
    error_message = "Enable private_service_access_config.enable_private_services_connection before creating Redis."
  }
  validation {
    condition     = var.cache == null ? true : var.cache.memory_size_gb >= 1 && floor(var.cache.memory_size_gb) == var.cache.memory_size_gb
    error_message = "Redis memory must be a positive whole number of GiB."
  }
  validation {
    condition     = var.cache == null ? true : contains(["BASIC", "STANDARD_HA"], var.cache.tier)
    error_message = "Redis tier must be BASIC or STANDARD_HA."
  }
  validation {
    condition     = var.cache == null ? true : contains(["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"], var.cache.maintenance_day) && var.cache.maintenance_hour_utc >= 0 && var.cache.maintenance_hour_utc <= 23 && floor(var.cache.maintenance_hour_utc) == var.cache.maintenance_hour_utc
    error_message = "Supply an uppercase weekday and a whole UTC hour from 0 to 23."
  }
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = "Labels for the new registry, cache and secret resources."
}
