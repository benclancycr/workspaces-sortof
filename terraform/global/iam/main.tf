provider aws {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "${var.remote_state_bucket}"
    key    = "${var.remote_state_bucket_key}"
    region = "${var.region}"
  }
}

resource "aws_iam_role" "role_developer" {
  name = "role_developer"

  assume_role_policy = <<EOF
    {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Action": "sts:AssumeRole",
        "Principal": {
            "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
        }
    ]
    }
    EOF
}

resource "aws_iam_role" "role_lambda" {
  name = "role_lambda"

  assume_role_policy = <<EOF
    {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Action": "sts:AssumeRole",
        "Principal": {
            "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
        }
    ]
    }
    EOF
}

resource "aws_iam_policy" "role_developer_policy" {
  name = "role_developer_policy"

  policy = <<EOF
        {
        "Version": "2012-10-17",
        "Statement": [
            {
            "Action": [
                "ec2:Describe*",
                "ec2:List*",
                "s3:List*",
                "s3:Put*"
            ],
            "Effect": "Allow",
            "Resource": "*"
            }
        ]
        }
    EOF
}

resource "aws_iam_role_policy_attchment" "role_developer_attach" {
  role       = "${aws_iam_role.role_developer.name}"
  policy_arn = "${aws_iam_policy.role_developer_policy.arn}"
}
