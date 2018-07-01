output "route53_zone" {
  value = "${aws_route53_zone.workstations.zone_id}"
}
