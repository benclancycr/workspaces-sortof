provider aws {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "companyid-remotestatebucket1098789"
    key    = "terraform/global/route53/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "companyid-remotestatebucket1098789"
    key    = "terraform/prod/terraform.tfstate"
    region = "${var.region}"
  }
}

resource "aws_route53_zone" "main" {
  name   = "${var.route53_zone_name}"
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
}

resource "aws_route53_zone" "workstations" {
  name = "workstations.${var.route53_zone_name}"
}

resource "aws_route53_record" "workstations-ns" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name    = "workstations.${var.route53_zone_name}"
  type    = "NS"
  ttl     = "30"

  records = [
    "${aws_route53_zone.workstations.name_servers.0}",
    "${aws_route53_zone.workstations.name_servers.1}",
    "${aws_route53_zone.workstations.name_servers.2}",
    "${aws_route53_zone.workstations.name_servers.3}",
  ]
}
