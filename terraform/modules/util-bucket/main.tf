# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

# create a bucket which uses the data account id as part of the name
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}
resource "aws_s3_bucket" "example" {
  bucket = "utils-${local.account_id}-${local.region}"
}