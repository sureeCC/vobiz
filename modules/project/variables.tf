variable "audit_services" {
  description = "Services for which this root owns Data Access audit settings."
  type        = set(string)
  default     = []
}

variable "billing_account_id" {
  description = "Billing account ID for new project creation."
  type        = string
  default     = ""
}

variable "create_project" {
  description = "Create a project through Project Factory; otherwise configure an existing project."
  type        = bool
  default     = false
}

variable "enabled_apis" {
  description = "Explicit service API list for this project."
  type        = list(string)
}

variable "folder_id" {
  description = "Optional parent folder ID for new project creation."
  type        = string
  default     = ""
}

variable "organization_id" {
  description = "Organisation ID for new project creation."
  type        = string
  default     = null
}

variable "project_boolean_policies" {
  description = "Constraint name without constraints/ prefix => enforced boolean."
  type        = map(bool)
  default     = {}
}

variable "project_iam_members" {
  description = "Stable key => additive project IAM role/member pair."
  type        = map(object({ role = string, member = string }))
  default     = {}
}

variable "project_id" {
  description = "Target GCP project ID; replace the mock PROJECT ID before planning."
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Replace PROJECT ID with a valid GCP project ID."
  }
}

variable "project_name" {
  description = "Display name, used only when creating a project."
  type        = string
  default     = "Vobiz production"
}

variable "service_accounts" {
  description = "Account ID => account metadata and project roles; no keys are generated."
  type = map(object({
    display_name = string
    description  = string
    roles        = set(string)
  }))
  default = {}
}
