output "bucket_id" {
  value = "${aws_s3_bucket.bucket_for_keys.id}"
}

output "bucket_arn" {
  value = "${aws_s3_bucket.bucket_for_keys.arn}"
}
