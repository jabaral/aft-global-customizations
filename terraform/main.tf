# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0
#
module "util_buckets" {
  source = "../../modules/util-bucket"
  providers = {
    aws = aws
  }
}