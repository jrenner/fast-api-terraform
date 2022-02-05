

## API GATEWAY

data "aws_iam_policy_document" "api_policy" {
  statement {
    effect = "Allow"
    actions = [
      "execute-api:Invoke"
    ]
    resources = [
      "execute-api:/*"
    ]
	principals {
	  type = "*"
	  identifiers = ["*"]
	}
  }
}

resource "aws_api_gateway_rest_api" "learn_rest_api" {
  name        = "learn-rest-api"
  description = "test api gateway for learning terraform"
  policy      = data.aws_iam_policy_document.api_policy.json
}

resource "aws_api_gateway_resource" "api" {
  rest_api_id = aws_api_gateway_rest_api.learn_rest_api.id
  parent_id   = aws_api_gateway_rest_api.learn_rest_api.root_resource_id
  path_part   = "api"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.learn_rest_api.id
  parent_id   = aws_api_gateway_resource.api.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id      = aws_api_gateway_rest_api.learn_rest_api.id
  resource_id      = aws_api_gateway_resource.proxy.id
  http_method      = "ANY"
  api_key_required = false
  authorization    = "NONE"
}

resource "aws_api_gateway_integration" "proxy" {
  rest_api_id             = aws_api_gateway_rest_api.learn_rest_api.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.proxy_lambda.invoke_arn
  content_handling        = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_deployment" "deployment" {
	depends_on = [
		aws_api_gateway_integration.proxy
	]
	rest_api_id = aws_api_gateway_rest_api.learn_rest_api.id
	stage_name = "dev"
	stage_description = "deployed at: ${timestamp()}"

	lifecycle {
	  create_before_destroy = true
	}
}