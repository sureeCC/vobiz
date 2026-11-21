### Common ###
project_id = "gcp-voice-infra"
region     = "asia-south1"

### VNet ###
network_name = "prod-vpc"
subnets = [
  {
    subnet_name           = "public"
    subnet_ip             = "10.80.16.0/24"
    subnet_region         = "asia-south1"
    subnet_private_access = "false"
    subnet_flow_logs      = "false"
    description           = "Public subnet"
  },
  {
    subnet_name           = "private"
    subnet_ip             = "10.80.0.0/20"
    subnet_region         = "asia-south1"
    subnet_private_access = "true"
    subnet_flow_logs      = "true"
    description           = "Worker Nodes & associated services"
  },
  {
    subnet_name               = "subnet-03"
    subnet_ip                 = "10.80.30.0/24"
    subnet_region             = "asia-south1"
    subnet_flow_logs          = "true"
    subnet_flow_logs_interval = "INTERVAL_10_MIN"
    subnet_flow_logs_sampling = 0.7
    subnet_flow_logs_metadata = "INCLUDE_ALL_METADATA"
    description               = "Additional subnet"
  }
]

secondary_ranges = {
  private = [
    {
      range_name    = "pod-secondary"
      ip_cidr_range = "10.84.0.0/16"
    },
  ]
}

nats = [
  {
    name                               = "prod-cloud-nat"
    nat_ip_allocate_option             = "AUTO_ONLY"
    source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

    subnetworks = [
      {
        name = "projects/gcp-voice-infra/regions/asia-south1/subnetworks/private"
        source_ip_ranges_to_nat = [
          "PRIMARY_IP_RANGE",
          "LIST_OF_SECONDARY_IP_RANGES"
        ]

        secondary_ip_range_names = [
          "pod-secondary"
        ]
    }]

    log_config = {
      enable = true
      filter = "ALL"
    }
}]

routes = [
  {
    name              = "egress-internet"
    description       = "route through IGW to access internet"
    destination_range = "0.0.0.0/0"
    tags              = ["egress-inet"]
    next_hop_internet = true
    priority          = 1000
  }
]

### Router ###
router_name        = "prod-vnet-router"
network            = "prod-vpc"
router_description = "prod-vpc router"
