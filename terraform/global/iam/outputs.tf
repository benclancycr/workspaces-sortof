output "role_lambda_arn" {
  value = "${aws_iam_role.role_lambda.arn}"
}

output "role_developer_arn" {
  value = "${aws_iam_role.role_developer.arn}"
}
