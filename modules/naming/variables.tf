variable "application" {
  type    = string
  default = "vobiz"
  validation {
    condition     = can(regex("^[a-z][a-z0-9]*(-[a-z0-9]+)*$", var.application))
    error_message = "Application must be a lowercase name using letters, digits and single hyphens."
  }
}
variable "environment" {
  type = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9]*(-[a-z0-9]+)*$", var.environment))
    error_message = "Environment must be a lowercase name using letters, digits and single hyphens."
  }
}
variable "region" {
  type = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9]*(-[a-z0-9]+)*$", var.region))
    error_message = "Region must be a lowercase region identifier."
  }
}
variable "resources" {
  type = map(object({
    shortcode  = string
    sequence   = optional(number, 1)
    region     = optional(string)
    max_length = optional(number, 63)
  }))
  validation {
    condition = alltrue([for item in var.resources :
      can(regex("^[a-z]{1,8}$", item.shortcode)) &&
      item.sequence >= 1 && item.sequence <= 999 && floor(item.sequence) == item.sequence &&
      item.max_length >= 1 && floor(item.max_length) == item.max_length &&
      (item.region == null ? true : can(regex("^[a-z][a-z0-9]*(-[a-z0-9]+)*$", item.region)))
    ])
    error_message = "Use a lowercase 1-8 letter shortcode, integer sequence 1-999, positive integer length limit and valid optional region."
  }
}
