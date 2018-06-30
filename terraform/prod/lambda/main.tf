provider aws {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "companyid-remotestatebucket1098789"
    key    = "terraform/prod/lambda/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "iam" {
  backend = "s3"

  config {
    bucket = "companyid-remotestatebucket1098789"
    key    = "terraform/global/iam/terraform.tfstate"
    region = "${var.region}"
  }
}

data "terraform_remote_state" "s3" {
  backend = "s3"

  config {
    bucket = "companyid-remotestatebucket1098789"
    key    = "terraform/global/s3/terraform.tfstate"
    region = "${var.region}"
  }
}

resource "aws_lambda_function" "ec2-start" {
  filename      = "./ec2-start.zip"
  function_name = "ec2-start"
  role          = "${data.terraform_remote_state.iam.role_lambda_arn}"
  handler       = "ec2-start.lambda_handler"
  runtime       = "python2.7"
}

resource "aws_lambda_function" "ec2-stop" {
  filename      = "./ec2-stop.zip"
  function_name = "ec2-stop"
  role          = "${data.terraform_remote_state.iam.role_lambda_arn}"
  handler       = "ec2-stop.lambda_handler"
  runtime       = "python2.7"
}

# resource "aws_lambda_function" "ec2-create" {
#   filename      = "./ec2-create.zip"
#   function_name = "ec2-create"
#   role          = "${data.terraform_remote_state.iam.role_lambda_arn}"
#   handler       = "ec2-create.lambda_handler"
#   runtime       = "python2.7"
# environment {
#  variables {
#    bucket_id = "${data.terraform_remote_state.s3.bucket_id}"
#  }
# }
# }

