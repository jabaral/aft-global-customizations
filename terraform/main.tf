# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0
#
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

module "util_buckets" {
  source = "./modules/util-bucket"
  suffix = "sdfsd"
  providers = {
    aws = aws
  }
}

module "images_bucket" {
  source = "./modules/util-bucket"
  suffix = "images"
  providers = {
    aws = aws
  }
}
