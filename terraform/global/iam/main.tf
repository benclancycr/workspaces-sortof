provider aws {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "companyid-remotestatebucket1098789"
    key    = "terraform/global/iam/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "template_file" "local_file_role_developer" {
  template = "${file("${path.module}/files/role_developer.json")}"
}

data "template_file" "local_file_role_lambda" {
  template = "${file("${path.module}/files/role_lambda.json")}"
}

data "template_file" "local_file_role_developer_policy" {
  template = "${file("${path.module}/files/role_developer_policy.json")}"
}

data "template_file" "local_file_role_lambda_policy" {
  template = "${file("${path.module}/files/role_lambda_policy.json")}"
}

resource "aws_iam_role" "role_developer" {
  name = "${var.role_developer_name}"

  assume_role_policy = "${data.template_file.local_file_role_developer.rendered}"
}

resource "aws_iam_role" "role_lambda" {
  name = "${var.role_lambda_name}"

  assume_role_policy = "${data.template_file.local_file_role_lambda.rendered}"
}

resource "aws_iam_policy" "role_developer_policy" {
  name = "${var.role_developer_policy_name}"

  policy = "${data.template_file.local_file_role_developer_policy.rendered}"
}

resource "aws_iam_policy" "role_lambda_policy" {
  name = "${var.role_developer_policy_name}"

  policy = "${data.template_file.local_file_role_lambda_policy.rendered}"
}

resource "aws_iam_role_policy_attachment" "role_developer_attach" {
  role       = "${aws_iam_role.role_developer.name}"
  policy_arn = "${aws_iam_policy.role_developer_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "role_lambda_attach" {
  role       = "${aws_iam_role.role_lambda.name}"
  policy_arn = "${aws_iam_policy.role_lambda_policy.arn}"
}
