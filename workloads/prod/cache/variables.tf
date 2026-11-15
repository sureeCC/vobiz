variable "project_id" {
  type        = string
  description = "Existing GCP project ID; placeholder values are rejected."
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Use an existing GCP project ID: 6-30 lowercase letters, digits or hyphens."
  }
}
variable "region" {
  type    = string
  default = "asia-south1"
}

variable "name" {
  type = string
}
variable "network_id" {
  type        = string
  description = "Existing VPC ID/self-link, including its host project for Shared VPC."
}
variable "memory_size_gb" {
  type    = number
  default = 5
  validation {
    condition     = var.memory_size_gb >= 1 && floor(var.memory_size_gb) == var.memory_size_gb
    error_message = "Redis memory must be a positive whole number of GiB."
  }
}
variable "tier" {
  type    = string
  default = "STANDARD_HA"
  validation {
    condition     = contains(["BASIC", "STANDARD_HA"], var.tier)
    error_message = "Use BASIC or STANDARD_HA."
  }
}
variable "redis_version" {
  type    = string
  default = "REDIS_7_2"
}
variable "connect_mode" {
  type    = string
  default = "PRIVATE_SERVICE_ACCESS"
  validation {
    condition     = contains(["DIRECT_PEERING", "PRIVATE_SERVICE_ACCESS"], var.connect_mode)
    error_message = "Use DIRECT_PEERING or PRIVATE_SERVICE_ACCESS."
  }
}
variable "reserved_ip_range" {
  type        = string
  default     = null
  description = "PSA allocated range name, or a CIDR for DIRECT_PEERING."
}
variable "maintenance_day" {
  type    = string
  default = "SUNDAY"
  validation {
    condition     = contains(["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"], var.maintenance_day)
    error_message = "Use an uppercase weekday."
  }
}
variable "maintenance_hour_utc" {
  type    = number
  default = 0
  validation {
    condition     = var.maintenance_hour_utc >= 0 && var.maintenance_hour_utc <= 23 && floor(var.maintenance_hour_utc) == var.maintenance_hour_utc
    error_message = "Maintenance hour must be a whole UTC hour from 0 to 23."
  }
}
