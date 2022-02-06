locals {
	local_lambda_zip = "${path.module}/../../test_lambda/deploy/lambda-package.zip"
}

resource "aws_s3_bucket_object" "lambda_package" {
	bucket = "jrenner-terraform"
	key = "learn_lambda_package.zip"
	source = local.local_lambda_zip
	etag = md5(filebase64(local.local_lambda_zip))
}

data "aws_iam_policy_document" "lambda" {
	statement {
		effect = "Allow"
		actions = [
			"sts:AssumeRole",
		]
		principals {
			type = "Service"
			identifiers = [
				"lambda.amazonaws.com"
			]
		}
	}
}

data "aws_iam_policy_document" "lambda_logging" {
	statement {
		effect = "Allow"
		actions = [
			"logs:CreateLogGroup",
			"logs:CreateLogStream",
			"logs:PutLogEvents",
		]
		resources = [
			"arn:aws:logs:*:*:*"
		]
	}
}

resource "aws_iam_policy" "lambda_logging" {
	name = "lambda_logging"
	path = "/"
	policy = data.aws_iam_policy_document.lambda_logging.json
}

resource "aws_iam_role" "lambda" {
	name = "lambda-role"
	assume_role_policy = data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
	role = aws_iam_role.lambda.name
	policy_arn = aws_iam_policy.lambda_logging.arn
}

# resource "aws_iam_role_policy" "lambda" {
# 	name = "lambda-role"
# 	role = aws_iam_role.lambda.id
# 	policy = data.aws_iam_policy_document.lambda.json
# }

resource "aws_lambda_function" "proxy" {
	function_name = "learn-api-proxy-lambda"
	handler = "api_server.handler"
	runtime = "python3.7"
	role = aws_iam_role.lambda.arn
	memory_size = 256
	timeout = 30

	s3_bucket = "jrenner-terraform"
	s3_key = aws_s3_bucket_object.lambda_package.id
	source_code_hash = base64sha256(filebase64(local.local_lambda_zip))
	environment {
		variables = {
			STAGE = var.stage
		}
	}
}

resource "aws_lambda_permission" "apigw_proxy" {
	statement_id = "AllowExecutionFromAPIGateway"
	action = "lambda:InvokeFunction"
	function_name = aws_lambda_function.proxy.function_name
	principal = "apigateway.amazonaws.com"
}