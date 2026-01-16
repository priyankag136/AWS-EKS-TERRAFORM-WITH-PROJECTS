vpc_cidr = "10.0.0.0/16"

public_subnet_cidr = [ 
    "10.0.1.0/24", 
    "10.0.2.0/24", 
    "10.0.3.0/24" 
]

private_subnet_cidr = [ 
    "10.0.4.0/24", 
    "10.0.5.0/24", 
    "10.0.6.0/24" 
]

region = "eu-west-3"

availability_zones = [ 
    "eu-west-3a",
    "eu-west-3b", 
    "eu-west-3c"
]

eks_cluster_name = "my-eks-cluster"

cluster_version = "1.30"

node_groups = {
  default = {
    instance_types = ["t3.micro"]
    capacity_type = "ON_DEMAND"   

    scaling_config = {
        desired_size = 2
        max_size = 3
        min_size = 1
    }
  }
}
