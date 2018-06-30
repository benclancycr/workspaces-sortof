provider aws {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "companyid-remotestatebucket1098789"
    key    = "terraform/global/s3/terraform.tfstate"
    region = "eu-west-1"
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
