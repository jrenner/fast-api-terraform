locals {
  region = "us-west-2"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  backend "s3" {
    bucket = "jrenner-terraform"
    key    = "tf_state/tutorial"
    region = "us-west-2"
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "private"
  region  = "us-west-2"
}

resource "aws_instance" "app_server" {
  ami           = "ami-08d70e59c07c61a3a"
  instance_type = "t2.micro"

  tags = {
    Name = var.instance_name
  }
}

resource "aws_s3_bucket" "jrenner_learn_bucket" {
  bucket = "jrenner-learn-bucket"
  acl    = "private"

  tags = {
    Name = "jrenner learn bucket"
  }
}

data "aws_iam_policy_document" "learn_policy_doc" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
    ]
    resources = [
      aws_s3_bucket.jrenner_learn_bucket.arn,
      "${aws_s3_bucket.jrenner_learn_bucket.arn}/*"
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
}

module "lambda" {
  source = "./lambda"
  stage = var.env
}
