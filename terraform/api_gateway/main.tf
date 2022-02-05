

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

resource "aws_api_gateway_resource" "main" {
  rest_api_id = aws_api_gateway_rest_api.learn_rest_api.id
  parent_id   = aws_api_gateway_rest_api.learn_rest_api.root_resource_id
  path_part   = "main"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.learn_rest_api.id
  parent_id   = aws_api_gateway_resource.main.id
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
