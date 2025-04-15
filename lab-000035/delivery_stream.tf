resource "aws_kinesis_firehose_delivery_stream" "delivery_stream" {
  name        = "${var.project_name}-delivery-stream"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = aws_s3_bucket.datalake.arn

    # Buffer settings
    buffering_size = 1
    buffering_interval = 60

    # Prefix for S3 objects
    prefix = "data/raw"
    # Error output prefix
    error_output_prefix = "data/error"

    dynamic_partitioning_configuration {
      enabled = "false"
    }
  }
}

# IAM role for Kinesis Firehose
resource "aws_iam_role" "firehose_role" {
  name = "${var.project_name}-firehose-service-role-${var.aws_region}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for Kinesis Firehose to access S3
resource "aws_iam_role_policy" "firehose_policy" {
  name = "${var.project_name}-firehose-policy"
  role = aws_iam_role.firehose_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.datalake.arn,
          "${aws_s3_bucket.datalake.arn}/*"
        ]
      }
    ]
  })
}
