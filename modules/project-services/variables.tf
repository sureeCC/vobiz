variable "project_id" {
  type        = string
  description = "Project in which to enable explicitly selected APIs."
}
variable "activate_apis" {
  type        = list(string)
  description = "Service API names owned by this deployment state."
}
