# create a bucket which uses the data account id as part of the name
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
