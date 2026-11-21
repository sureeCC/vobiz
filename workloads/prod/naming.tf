variable "naming_sequences" {
  type        = map(number)
  default     = {}
  description = "Stable sequence assignments keyed like subnet/private, secret/app, repository/app, nat/egress, or cache. Defaults to 1; repeated shortcodes in one region require distinct assignments."
  validation {
    condition     = alltrue([for key in keys(var.naming_sequences) : contains(keys(local.naming_inventory), key)])
    error_message = "Naming sequence keys must match configured resource inventory keys; see the resource_names output."
  }
  validation {
    condition     = alltrue([for sequence in values(var.naming_sequences) : sequence >= 1 && sequence <= 999 && floor(sequence) == sequence])
    error_message = "Naming sequences must be whole numbers from 1 to 999."
  }
}
locals {
  environment    = basename(abspath(path.root))
  subnets_by_key = { for subnet in var.subnets : subnet.subnet_name => subnet }
  naming_inventory = merge(
    {
      vpc    = { shortcode = "vn" }
      router = { shortcode = "cr" }
    },
    var.cache == null ? {} : { cache = { shortcode = "rc", max_length = 40 } },
    var.private_service_access_config.enable_private_services_connection ? { psa = { shortcode = "pa" } } : {},
    { for subnet in var.subnets : "subnet/${subnet.subnet_name}" => { shortcode = "sn", region = coalesce(subnet.subnet_region, var.region) } },
    merge({}, [for subnet, ranges in var.secondary_ranges : {
      for range in ranges : "range/${subnet}/${range.range_name}" => {
        shortcode = "sr", region = coalesce(local.subnets_by_key[subnet].subnet_region, var.region)
      }
    }]...),
    { for route in var.routes : "route/${route.name}" => { shortcode = "rt" } },
    { for rule in var.ingress_rules : "ingress/${rule.name}" => { shortcode = "fi" } },
    { for rule in var.egress_rules : "egress/${rule.name}" => { shortcode = "fe" } },
    { for nat in var.nats : "nat/${nat.name}" => { shortcode = "nt" } },
    { for name, repo in var.repositories : "repository/${name}" => { shortcode = "ar" } },
    { for name, secret in var.secrets : "secret/${name}" => { shortcode = "sc" } }
  )
}
module "naming" {
  source      = "../../modules/naming"
  application = "vobiz"
  environment = local.environment
  region      = var.region
  resources = { for key, item in local.naming_inventory : key => merge(item, {
    sequence = lookup(var.naming_sequences, key, 1)
  }) }
}
locals {
  subnet_names  = { for subnet in var.subnets : subnet.subnet_name => module.naming.names["subnet/${subnet.subnet_name}"] }
  named_subnets = [for subnet in var.subnets : merge(subnet, { subnet_name = local.subnet_names[subnet.subnet_name] })]
  named_ranges = { for subnet, ranges in var.secondary_ranges : local.subnet_names[subnet] => [
    for range in ranges : merge(range, { range_name = module.naming.names["range/${subnet}/${range.range_name}"] })
  ] }
  named_psa = merge(var.private_service_access_config, {
    address_name = var.private_service_access_config.enable_private_services_connection ? module.naming.names["psa"] : var.private_service_access_config.address_name
  })
  named_nats = [for nat in var.nats : merge(nat, {
    name = module.naming.names["nat/${nat.name}"]
    subnetworks = [for subnet in nat.subnetworks : merge(subnet, {
      name = contains(keys(local.subnet_names), subnet.name) ? "projects/${var.project_id}/regions/${coalesce(local.subnets_by_key[subnet.name].subnet_region, var.region)}/subnetworks/${local.subnet_names[subnet.name]}" : subnet.name
      secondary_ip_range_names = subnet.secondary_ip_range_names == null ? null : [
        for range in subnet.secondary_ip_range_names : lookup(module.naming.names, "range/${subnet.name}/${range}", range)
      ]
    })]
  })]
  named_repositories = { for key, repo in var.repositories : key => merge(repo, { repository_id = module.naming.names["repository/${key}"] }) }
  named_secrets      = { for key, secret in var.secrets : key => merge(secret, { secret_id = module.naming.names["secret/${key}"] }) }
}
output "resource_names" {
  value       = module.naming.names
  description = "Generated physical names: shortcode-vobiz-workload_folder-region-NNN."
}
