### Terraform Setup Section ###

provider aws {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "companyid-remotestatebucket1098789"
    key    = "terraform/prod/terraform.tfstate"
    region = "eu-west-1"
  }
}

### Data Section ###
data "aws_availability_zones" "available" {}

### VPC Section ###
resource "aws_vpc" "main" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name = "workspaces-vpc"
  }
}

### Subnet Section ###
resource "aws_subnet" "workspaces_az1_subnet" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.workspace_az1_subnet_cidr}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"

  tags {
    Name = "Subnet_Workstations"
  }
}

resource "aws_subnet" "workspaces_az2_subnet" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.workspace_az2_subnet_cidr}"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"

  tags {
    Name = "Subnet_Workstations"
  }
}

resource "aws_subnet" "proxy_az1_subnet" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.proxy_az1_subnet_cidr}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"

  tags {
    Name = "Subnet_Proxy"
  }
}

resource "aws_subnet" "proxy_az2_subnet" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.proxy_az2_subnet_cidr}"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"

  tags {
    Name = "Subnet_Proxy"
  }
}

### Route Tables Section ###

resource "aws_route_table" "workspace_route_table" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "Route table used by workspace subnets"
  }
}

resource "aws_route_table" "proxy_route_table" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Description = "Route table used by proxy subnets"
  }
}

resource "aws_route_table_association" "workspace_association_1" {
  subnet_id      = "${aws_subnet.workspaces_az1_subnet.id}"
  route_table_id = "${aws_route_table.workspace_route_table.id}"
}

resource "aws_route_table_association" "workspace_association_2" {
  subnet_id      = "${aws_subnet.workspaces_az2_subnet.id}"
  route_table_id = "${aws_route_table.workspace_route_table.id}"
}

resource "aws_route_table_association" "proxy_association_1" {
  subnet_id      = "${aws_subnet.proxy_az1_subnet.id}"
  route_table_id = "${aws_route_table.proxy_route_table.id}"
}

resource "aws_route_table_association" "proxy_association_2" {
  subnet_id      = "${aws_subnet.proxy_az2_subnet.id}"
  route_table_id = "${aws_route_table.proxy_route_table.id}"
}

### NACL Section ###

resource "aws_network_acl" "workspace_network_acl" {
  vpc_id = "${aws_vpc.main.id}"

  subnet_ids = [
    "${aws_subnet.workspaces_az1_subnet.id}",
    "${aws_subnet.workspaces_az2_subnet.id}",
  ]

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags {
    Name = "nacl_workspaces"
  }
}

resource "aws_network_acl" "proxy_network_acl" {
  vpc_id = "${aws_vpc.main.id}"

  subnet_ids = [
    "${aws_subnet.proxy_az1_subnet.id}",
    "${aws_subnet.proxy_az2_subnet.id}",
  ]

  egress {
    protocol   = "-1"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags {
    Name = "nacl_proxy"
  }
}

### Security Groups Section ###
resource "aws_security_group" "workspace_sg" {
  name        = "workspaces-sg"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "proxy_sg" {
  name        = "proxy-sg"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

### VPC Endpoint Section ###
resource "aws_vpc_endpoint" "private-s3" {
  vpc_id          = "${aws_vpc.main.id}"
  service_name    = "com.amazonaws.eu-west-1.s3"
  route_table_ids = ["${aws_route_table.proxy_route_table.id}"]

  policy = <<POLICY
    {
        "Statement": [
            {
                "Action": "*",
                "Effect":"Allow",
                "Resource": "*",
                "Principal": "*"
            }
        ]
    }
    POLICY
}

### VPN Section ###
resource "aws_vpn_gateway" "gw_vpn" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Description = "Gateway used for VPN to on-prem"
  }
}

resource "aws_customer_gateway" "gw_customer" {
  bgp_asn    = "${var.customer_bgp_asn}"
  ip_address = "${var.customer_gateway_tunnel_ip}"
  type       = "ipsec.1"
}

resource "aws_vpn_connection" "vpn_connection" {
  vpn_gateway_id      = "${aws_vpn_gateway.gw_vpn.id}"
  customer_gateway_id = "${aws_customer_gateway.gw_customer.id}"
  type                = "ipsec.1"
  static_routes_only  = true
}

### IGW Section ###

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Description = "Internet gateway used by ${aws_vpc.main.id}"
  }
}

# ### VPC Peering Section ###
# resource "aws_vpc_peering_connection" "peering_connection" {
#   peer_owner_id = "${var.peer_owner_id}"
#   peer_vpc_id   = "${var.peer_vpc_id}"
#   vpc_id        = "${aws_vpc.main.id}"
# }

