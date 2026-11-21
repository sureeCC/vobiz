variable "project_id" { type = string }
variable "region" { type = string }
variable "labels" {
  type    = map(string)
  default = {}
}
variable "secrets" {
  type = map(object({
    secret_id             = optional(string)
    accessors             = optional(set(string), [])
    replication_locations = optional(set(string), [])
  }))
  default     = {}
  description = "Physical secret IDs and accessor IAM members. Empty locations uses automatic replication. Values are populated outside Terraform."
}
