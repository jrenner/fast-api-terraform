locals {
  domain_name = "fast.inner-trac.org"
}

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

# ACM certificate

resource "aws_acm_certificate" "learn" {
  domain_name = local.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_zone" "learn" {
  name = local.domain_name
}

resource "aws_route53_record" "learn" {
  for_each = {
    for dvo in aws_acm_certificate.learn.domain_validation_options : dvo.domain_name => {
      name = dvo.resource_record_name
      record = dvo.resource_record_value
      type = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name = each.value.name
  records = [each.value.record]
  ttl = 60
  type = each.value.type
  zone_id = aws_route53_zone.learn.zone_id
}

resource "aws_acm_certificate_validation" "learn" {
  certificate_arn = aws_acm_certificate.learn.arn
  validation_record_fqdns = [for record in aws_route53_record.learn : record.fqdn]
}

# Custom Domain Name

resource "aws_api_gateway_domain_name" "learn" {
  domain_name = local.domain_name
  certificate_arn = aws_acm_certificate_validation.learn.certificate_arn
}

resource "aws_route53_record" "learn-apigw" {
  name = aws_api_gateway_domain_name.learn.domain_name
  type = "A"
  zone_id = aws_route53_zone.learn.id

  alias {
    evaluate_target_health = true
    name = aws_api_gateway_domain_name.learn.cloudfront_domain_name
    zone_id = aws_api_gateway_domain_name.learn.cloudfront_zone_id
  }
}

# API Mapping for domain name

resource "aws_api_gateway_base_path_mapping" "learn" {
  api_id = aws_api_gateway_rest_api.learn_rest_api.id
  stage_name = var.stage
  domain_name = aws_api_gateway_domain_name.learn.domain_name
}