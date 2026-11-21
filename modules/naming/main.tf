locals {
  names = { for key, item in var.resources : key => format(
    "%s-%s-%s-%s-%03d",
    item.shortcode, var.application, var.environment,
    coalesce(item.region, var.region), item.sequence
  ) }
}
