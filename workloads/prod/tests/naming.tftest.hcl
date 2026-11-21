variables {
  environment = "prod"
  region      = "eastus"
  resources = {
    cache  = { shortcode = "rc" }
    secret = { shortcode = "sc" }
  }
}
run "requested_format" {
  command = plan
  module { source = "../../modules/naming" }
  assert {
    condition     = output.names.cache == "rc-vobiz-prod-eastus-001" && output.names.secret == "sc-vobiz-prod-eastus-001"
    error_message = "Names must use shortcode-vobiz-environment-region-NNN."
  }
}
run "regional_and_stable_sequences" {
  command = plan
  module { source = "../../modules/naming" }
  variables {
    region = "asia-south1"
    resources = {
      first    = { shortcode = "sc", sequence = 2 }
      later    = { shortcode = "sc", sequence = 7 }
      regional = { shortcode = "sc", sequence = 2, region = "asia-south2" }
    }
  }
  assert {
    condition     = output.names.first == "sc-vobiz-prod-asia-south1-002" && output.names.later == "sc-vobiz-prod-asia-south1-007" && output.names.regional == "sc-vobiz-prod-asia-south2-002"
    error_message = "Explicit sequences and per-resource regions must remain unchanged."
  }
}
run "reject_collisions" {
  command = plan
  module { source = "../../modules/naming" }
  variables { resources = { first = { shortcode = "sc" }, second = { shortcode = "sc" } } }
  expect_failures = [output.names]
}
run "reject_sequence_zero" {
  command = plan
  module { source = "../../modules/naming" }
  variables { resources = { first = { shortcode = "sc", sequence = 0 } } }
  expect_failures = [var.resources]
}
run "reject_sequence_overflow" {
  command = plan
  module { source = "../../modules/naming" }
  variables { resources = { first = { shortcode = "sc", sequence = 1000 } } }
  expect_failures = [var.resources]
}
run "reject_fractional_sequence" {
  command = plan
  module { source = "../../modules/naming" }
  variables { resources = { first = { shortcode = "sc", sequence = 1.5 } } }
  expect_failures = [var.resources]
}
run "reject_length_overflow" {
  command = plan
  module { source = "../../modules/naming" }
  variables { resources = { first = { shortcode = "rc", max_length = 10 } } }
  expect_failures = [output.names]
}
run "reject_invalid_context" {
  command = plan
  module { source = "../../modules/naming" }
  variables { environment = "PROD / invalid" }
  expect_failures = [var.environment]
}
