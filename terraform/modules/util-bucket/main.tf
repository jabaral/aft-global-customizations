# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.id
}

# bucket creation
#checkov:skip=CKV2_AWS_62:Event notifications not required for utility buckets
#checkov:skip=CKV2_AWS_61:Lifecycle configuration not required for utility buckets
#checkov:skip=CKV_AWS_144:Cross-region replication not required for utility buckets
resource "aws_s3_bucket" "default" {
  bucket = "utils-${local.account_id}-${local.region}-${var.suffix}"
}

resource "aws_s3_bucket_versioning" "default" {
  bucket = aws_s3_bucket.default.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.default.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.default.arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "default" {
  bucket = aws_s3_bucket.default.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "default" {
  bucket = aws_s3_bucket.default.id

  target_bucket = aws_s3_bucket.default.id
  target_prefix = "log/"
}

resource "aws_kms_key" "default" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${local.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow S3 to use the key"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      }
    ]
  })
}

# Helper bucket
#checkov:skip=CKV2_AWS_62:Event notifications not required for utility buckets
#checkov:skip=CKV2_AWS_61:Lifecycle configuration not required for utility buckets
#checkov:skip=CKV_AWS_144:Cross-region replication not required for utility buckets
resource "aws_s3_bucket" "helper" {
  bucket = "helper-${local.account_id}-${local.region}"
}

resource "aws_s3_bucket_versioning" "helper" {
  bucket = aws_s3_bucket.helper.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "helper" {
  bucket = aws_s3_bucket.helper.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.helper.arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "helper" {
  bucket = aws_s3_bucket.helper.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "helper" {
  bucket = aws_s3_bucket.helper.id

  target_bucket = aws_s3_bucket.helper.id
  target_prefix = "log/"
}

resource "aws_kms_key" "helper" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${local.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow S3 to use the key"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      }
    ]
  })
}
