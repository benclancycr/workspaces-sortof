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
data "aws_availability_zones" "all" {}

### VPC Section ###
resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr}"

  tags {
    Name = "workspaces-vpc"
  }
}

### Subnet Section ###
resource "aws_subnet" "workspace_az1_subnet" {
  vpc_id     = "${aws.vpc.main.id}"
  cidr_block = "${var.workspace_az1_subnet_cidr}"

  tags {
    Name = "Subnet used by EC2 instances to provide Workstations"
  }
}

resource "aws_subnet" "workspace_az2_subnet" {
  vpc_id     = "${aws.vpc.main.id}"
  cidr_block = "${var.workspace_az1_subnet_cidr}"

  tags {
    Name = "Subnet used by EC2 instances to provide Workstations"
  }
}

resource "aws_subnet" "proxy_az1_subnet" {
  vpc_id     = "${aws.vpc.main.id}"
  cidr_block = "${var.proxy_az1_subnet_cidr}"

  tags {
    Name = "Subnet used by EC2 instances to provide proxy functionality"
  }
}

resource "aws_subnet" "proxy_az2_subnet" {
  vpc_id     = "${aws.vpc.main.id}"
  cidr_block = "${var.proxy_az2_subnet_cidr}"

  tags {
    Name = "Subnet used by EC2 instances to provide proxy functionality"
  }
}

### Route Tables Section ###

resource "aws_route_table" "workspace_route_table" {
  vpc_id = "${aws_vpc.main.id}"

  #route {
  # cidr_block = "0.0.0.0/0"


  #gateway_id = "${aws_elb."
  #}

  tags {
    Name = "Route table used by proxy subnets"
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
    "${aws_subnet.workspaces_az1_subnet_cidr.id}",
    "${aws_subnet.workspaces_az2_subnet_cidr.id}",
  ]

  egress {
    protocol   = "*"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = "*"
    to_port    = "*"
  }

  ingress {
    protocol   = "*"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = "*"
    to_port    = "*"
  }

  tags {
    Name = "main"
  }
}

resource "aws_network_acl" "proxy_network_acl" {
  vpc_id = "${aws_vpc.main.id}"

  subnet_ids = [
    "${aws_subnet.proxy_az1_subnet_cidr.id}",
    "${aws_subnet.proxy_az2_subnet_cidr.id}",
  ]

  egress {
    protocol   = "*"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = "*"
    to_port    = "*"
  }

  ingress {
    protocol   = "*"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = "*"
    to_port    = "*"

    tags {
      Name = "main"
    }
  }
}

### Security Groups Section ###
resource "aws_security_group" "workspace_sg" {
  name        = "sg-workspaces"
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
  name        = "sg-proxy"
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
                "Effect":"Allow"
                "Resource": "*"
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
    Description = "Internet gateway used by ${aws_vpc.main}"
  }
}

### VPC Peering Section ###
resource "aws_vpc_peering_connection" "peering_connection" {
  peer_owner_id = "${var.peer_owner_id}"
  peer_vpc_id   = "${var.peer_vpc_id}"
  vpc_id        = "${aws_vpc.main.id}"
}

# elb
# asg
# asg security groups
# ebs
# private zone
# dns conditional forwarder

# lambda's:
# ec2-start, ec2-stop, ec2-create-schedule, ec2-create-ad-hoc

resource "aws_lambda_function" "ec2-start" {
  filename      = "./lambda/ec2-start.zip"
  function_name = "ec2-start"
  role          = "${data.terraform_remote_state.iam.role_lambda_arn}"
  handler       = "start.handle"
  runtime       = "python2.7"
}
