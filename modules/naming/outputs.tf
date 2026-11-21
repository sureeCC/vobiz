output "names" {
  description = "Physical names keyed by stable caller-defined inventory identifiers."
  value       = local.names
  precondition {
    condition     = length(distinct(values(local.names))) == length(local.names)
    error_message = "Generated names collide. Assign unique sequences for each shortcode and region."
  }
  precondition {
    condition     = alltrue([for key, name in local.names : length(name) <= var.resources[key].max_length])
    error_message = "A generated name exceeds its resource length limit. Shorten the context; names are never truncated."
  }
}
