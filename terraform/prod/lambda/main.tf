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

resource "aws_cloudwatch_event_rule" "daily_morning_start" {
  name                = "daily_morning_start"
  description         = "Create an event every morning to invoke ec2-start lambda"
  schedule_expression = "cron(0 06 ? * MON-FRI *)"
}

resource "aws_cloudwatch_event_target" "check_daily_morning_start" {
  rule      = "${aws_cloudwatch_event_rule.daily_morning_start.name}"
  target_id = "${aws_lambda_function.ec2-start.function_name}"
  arn       = "${aws_lambda_function.ec2-start.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_ec2_start" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.ec2-start.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.daily_morning_start.arn}"
}

resource "aws_lambda_function" "ec2-stop" {
  filename      = "./ec2-stop.zip"
  function_name = "ec2-stop"
  role          = "${data.terraform_remote_state.iam.role_lambda_arn}"
  handler       = "ec2-stop.lambda_handler"
  runtime       = "python2.7"
}

resource "aws_cloudwatch_event_rule" "daily_evening_stop" {
  name                = "daily_evening_stop"
  description         = "Create an event every evening to invoke ec2-stop lambda"
  schedule_expression = "cron(0 19 ? * MON-FRI *)"
}

resource "aws_cloudwatch_event_target" "check_daily_evening_stop" {
  rule      = "${aws_cloudwatch_event_rule.daily_evening_stop.name}"
  target_id = "${aws_lambda_function.ec2-stop.function_name}"
  arn       = "${aws_lambda_function.ec2-stop.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_ec2_stop" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.ec2-stop.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.daily_evening_stop.arn}"
}

resource "aws_lambda_function" "ec2-create" {
  filename      = "./ec2-create.zip"
  function_name = "ec2-create"
  role          = "${data.terraform_remote_state.iam.role_lambda_arn}"
  handler       = "ec2-create.lambda_handler"
  runtime       = "python2.7"

  environment {
    variables {
      BUCKET_ID = "${data.terraform_remote_state.s3.bucket_id}"
    }
  }
}

resource "aws_lambda_permission" "allow_bucket_to_invoke_lambda" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.ec2-create.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${data.terraform_remote_state.s3.bucket_arn}"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "${data.terraform_remote_state.s3.bucket_id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.ec2-create.arn}"
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "SSH_PUB_KEYS/"
    filter_suffix       = ".pub"
  }
}
