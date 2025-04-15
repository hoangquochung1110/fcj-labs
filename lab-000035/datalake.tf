import {
  id = "${var.project_name}-datalake-bucket-0804"
  to = aws_s3_bucket.datalake
}

resource "aws_s3_bucket" "datalake" {
  bucket = "${var.project_name}-datalake-bucket-0804"

  lifecycle {
    prevent_destroy = true
  }
}
