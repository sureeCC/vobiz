### Common ###
project_id = "vobiz-analytics"
region     = "asia-south1"

### VNet ###
network_name = "prod-vpc"
subnets = [
  {
    subnet_name   = "subnet-01"
    subnet_ip     = "10.10.10.0/24"
    subnet_region = "asia-south1"
  },
  {
    subnet_name           = "subnet-02"
    subnet_ip             = "10.10.20.0/24"
    subnet_region         = "asia-south1"
    subnet_private_access = "true"
    subnet_flow_logs      = "true"
    description           = "This subnet has a description"
  },
  {
    subnet_name               = "subnet-03"
    subnet_ip                 = "10.10.30.0/24"
    subnet_region             = "asia-south1"
    subnet_flow_logs          = "true"
    subnet_flow_logs_interval = "INTERVAL_10_MIN"
    subnet_flow_logs_sampling = 0.7
    subnet_flow_logs_metadata = "INCLUDE_ALL_METADATA"
  }
]

secondary_ranges = {
  subnet-01 = [
    {
      range_name    = "subnet-01-secondary-01"
      ip_cidr_range = "192.168.64.0/24"
    },
  ]

  subnet-02 = []
}

routes = [
  {
    name              = "egress-internet"
    description       = "route through IGW to access internet"
    destination_range = "0.0.0.0/0"
    tags              = ["egress-inet"]
    next_hop_internet = true
  }
]

### Router ###
router_name        = "prod-vnet-router"
network            = ""
router_description = ""
nats = [{
  name                        = ""
  nat_ip_allocate_option      = ""
  auto_allocate_nat_ips       = "true"
  nat_ips                     = [""]
  source_subnetwork_ip_ranges = ""
  subnetworks = [{
    name                     = ""
    source_ip_ranges_to_nat  = [""]
    secondary_ip_range_names = [""]
  }]
  description                    = ""
  enable_dynamic_port_allocation = "true"
  log_config = {
    enable = "true"
    filter = "ERRORS_ONLY"
  }
}]
