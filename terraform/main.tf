locals {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  backend "s3" {
    bucket = "jrenner-terraform-state"
    key    = "tf_state/tutorial"
    region = "us-east-1"
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "private"
  region  = local.region
}

//resource "aws_instance" "app_server" {
//  ami           = "ami-08d70e59c07c61a3a"
//  instance_type = "t2.micro"
//
//  tags = {
//    Name = var.instance_name
//  }
//}

resource "aws_s3_bucket" "learn_bucket" {
  bucket = "jrenner-learn-bucket-2"
  acl    = "private"

  tags = {
    Name = "jrenner learn bucket 2"
  }
}

data "aws_iam_policy_document" "learn_policy_doc" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
    ]
    resources = [
      aws_s3_bucket.learn_bucket.arn,
      "${aws_s3_bucket.learn_bucket.arn}/*"
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "policy" {
  name        = "learn-policy"
  description = "my tutorial policy"
  policy      = data.aws_iam_policy_document.learn_policy_doc.json
}

module "api_gateway" {
  source = "./api_gateway"
  proxy_lambda = module.lambda.proxy_lambda
  stage = var.stage
}

module "lambda" {
  source = "./lambda"
  stage = var.stage
  lambda_package_bucket = aws_s3_bucket.learn_bucket.id
}
