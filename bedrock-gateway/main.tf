locals {
  gateway_configs = {
    for name, cfg in var.gateways : name => merge({
      enabled                 = true
      create_gateway          = true
      gateway_name            = null
      description             = null
      role_arn                = null
      gateway_type            = "custom_jwt"
      authorizer_type         = "CUSTOM_JWT"
      discovery_url           = null
      allowed_audience        = []
      allowed_clients         = []
      allowed_scopes          = []
      protocol_type           = "MCP"
      instructions            = null
      search_type             = "HYBRID"
      supported_versions      = []
      interception_points     = []
      interceptor_lambda_arn  = null
      pass_request_headers    = false
    }, cfg)
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["bedrock-agentcore.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "gateway" {
  for_each = var.create_knowledge_base_gateway ? {
    for name, cfg in local.gateway_configs : name => cfg
    if try(cfg.enabled, true) && try(cfg.create_gateway, true)
  } : {}

  name               = coalesce(try(each.value.role_name, null), "${var.name_prefix}-bedrock-gateway-${each.key}")
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = merge(var.tags, {
    Name = coalesce(try(each.value.role_name, null), "${var.name_prefix}-bedrock-gateway-${each.key}")
  })
}

resource "aws_bedrockagentcore_gateway" "this" {
  for_each = var.create_knowledge_base_gateway ? {
    for name, cfg in local.gateway_configs : name => cfg
    if try(cfg.enabled, true) && try(cfg.create_gateway, true)
  } : {}

  name        = coalesce(try(each.value.gateway_name, null), "${var.name_prefix}-gateway-${each.key}")
  description = each.value.description
  role_arn    = coalesce(try(each.value.role_arn, null), aws_iam_role.gateway[each.key].arn)

  authorizer_type = each.value.authorizer_type

  dynamic "authorizer_configuration" {
    for_each = each.value.authorizer_type == "CUSTOM_JWT" ? [1] : []
    content {
      custom_jwt_authorizer {
        discovery_url    = each.value.discovery_url
        allowed_audience = each.value.allowed_audience
        allowed_clients  = each.value.allowed_clients
        allowed_scopes   = each.value.allowed_scopes
      }
    }
  }

  protocol_type = each.value.protocol_type

  dynamic "protocol_configuration" {
    for_each = each.value.protocol_type == "MCP" ? [1] : []
    content {
      mcp {
        instructions       = each.value.instructions
        search_type        = each.value.search_type
        supported_versions = each.value.supported_versions
      }
    }
  }

  dynamic "interceptor_configuration" {
    for_each = length(each.value.interception_points) > 0 ? [1] : []
    content {
      interception_points = each.value.interception_points

      interceptor {
        lambda {
          arn = each.value.interceptor_lambda_arn
        }
      }

      input_configuration {
        pass_request_headers = each.value.pass_request_headers
      }
    }
  }
}

