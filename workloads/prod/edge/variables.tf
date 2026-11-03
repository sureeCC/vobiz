variable "enable_http_load_balancer" {
  description = "Enable only for Terraform-owned HTTP ingress with actual backends. GKE Gateway ownership is the default direction."
  type        = bool
  default     = false
}
variable "http_load_balancer_name" {
  description = "Optional HTTP load balancer name."
  type        = string
}
variable "http_address_name" {
  description = "Global HTTP frontend address name."
  type        = string
}
variable "armor_policy_name" {
  description = "Baseline Cloud Armor policy name."
  type        = string
}
variable "http_domains" {
  description = "Real domains owned by Vobiz; DNS must resolve to the LB for certificate provisioning."
  type        = list(string)
  default     = []
  validation {
    condition     = !var.enable_http_load_balancer || length(var.http_domains) > 0
    error_message = "Enabled HTTPS ingress requires at least one real domain."
  }
}
variable "http_backends" {
  description = "One default instance-group backend for the optional baseline. Use application routing for multi-service ingress."
  type = map(object({
    port                      = number
    port_name                 = string
    timeout_seconds           = number
    health_check_path         = string
    instance_group_self_links = list(string)
  }))
  default = {}
  validation {
    condition = !var.enable_http_load_balancer || (
      length(var.http_backends) == 1 && alltrue([for backend in values(var.http_backends) : length(backend.instance_group_self_links) > 0])
    )
    error_message = "The optional HTTP baseline requires exactly one populated backend; replace mocks first."
  }
}
variable "voice_address_names" {
  description = "Reserve standalone voice IPs only after the endpoint design is approved. VM-owned addresses belong to voice state instead."
  type        = set(string)
  default     = []
}
variable "dns_zones" {
  description = "Explicit public zones and records. Does not change registrar delegation or existing AWS DNS."
  type = map(object({
    domain      = string
    description = string
    records     = list(object({ name = string, type = string, ttl = number, records = list(string) }))
  }))
  default = {}
}
