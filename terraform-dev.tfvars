subnet_cidr_block = "10.0.48.0/24"
environment = "development"
subnet_cidr_blocks = [
    { cidr_block = "10.0.0.0/16", name = "dev_vpc" },
    { cidr_block = "10.0.10.0/24", name = "dev_subnet-1" }
]