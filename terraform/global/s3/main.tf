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

resource "aws_s3_bucket" "bucket_for_keys" {
  bucket = "${var.ssh_key_bucket_name}"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Description = "Bucket used to store ssh public keys"
  }
}
