variable "region" {
  default = "eu-west-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "workspace_az1_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "workspace_az2_subnet_cidr" {
  default = "10.0.2.0/24"
}

variable "proxy_az1_subnet_cidr" {
  default = "10.0.3.0/24"
}

variable "proxy_az2_subnet_cidr" {
  default = "10.0.4.0/24"
}

variable "customer_bgp_asn" {
  default = "65000"
}

variable "customer_gateway_tunnel_ip" {
  default = "172.0.0.1"
}

# variable "peer_owner_id" {}


# variable "peer_vpc_id" {}

