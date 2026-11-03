module "dns" {
  for_each = var.dns_zones
  source   = "terraform-google-modules/cloud-dns/google"
  version  = "7.2.1"

  project_id  = var.project_id
  name        = each.key
  domain      = each.value.domain
  description = each.value.description
  type        = "public"
  recordsets  = each.value.records
}
