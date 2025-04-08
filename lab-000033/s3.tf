resource "aws_s3_bucket" "app_bucket" {
  bucket = var.app_bucket
}

# Configure Object Ownership setting
resource "aws_s3_bucket_ownership_controls" "app_bucket" {
  bucket = aws_s3_bucket.app_bucket.bucket
  
  rule {
    object_ownership = "ObjectWriter"
  }
}


# Set the bucket ACL (commonly needed with Object Ownership)
resource "aws_s3_bucket_acl" "app_bucket" {
  bucket = aws_s3_bucket.app_bucket.bucket
  acl    = "public-read"  # Set to appropriate value: private, public-read, etc.

  # This dependency ensures ownership controls are set before ACL
  depends_on = [aws_s3_bucket_ownership_controls.app_bucket]
}


data "aws_partition" "current" {}

data "aws_region" "current" {}