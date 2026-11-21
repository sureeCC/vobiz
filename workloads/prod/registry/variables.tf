variable "project_id" { type = string }
variable "region" { type = string }
variable "labels" {
  type    = map(string)
  default = {}
}
variable "repositories" {
  type = map(object({
    repository_id  = optional(string)
    description    = optional(string, "Vobiz Docker images")
    readers        = optional(set(string), [])
    writers        = optional(set(string), [])
    immutable_tags = optional(bool, true)
  }))
  default     = {}
  description = "Physical Docker repository IDs and repository-scoped IAM members."
}
