# =============================================================================
# Root module wiring.
#
# Implements the "DevOps Responsibilities" from the AgentCore IaC & CI/CD setup
# guide. The starter toolkit (`agentcore deploy`) still builds/pushes the agent
# container in CI/CD; Terraform owns the surrounding platform and points the
# toolkit at these resources so it does not create duplicates:
#
#   create_iam_scoped        -> module "iam_execution"   [DONE] runtime role (guide Step 4)
#                                                                + invoke Lambda role (Step 5)
#   create_ecr               -> module "ecr"              [DONE] ECR repository (Step 6)
#   create_lambda_invoke     -> module "lambda_invoke"    [DONE] invoke Lambda function (Step 3)
#   create_api_gateway       -> module "api_gateway"      [DONE] REST API POST /chat + CORS (Step 9)
#   create_bedrock_guardrail -> module "bedrock_guardrail" [DONE] content filters + topics + PII (deliverable 1)
#   create_observability     -> module "observability"   model-invocation logging + budget
# =============================================================================

# Deliverable 3 / guide Steps 4 & 5: execution roles + least-privilege permissions.
module "iam_execution" {
  count  = var.create_iam_scoped ? 1 : 0
  source = "./modules/iam-execution"

  name_prefix                      = var.resource_prefix
  tags                             = local.common_tags
  allowed_model_arns               = var.allowed_model_arns
  allowed_ecr_repository_arns      = var.allowed_ecr_repository_arns
  allowed_guardrail_arns           = var.create_bedrock_guardrail ? concat(var.allowed_guardrail_arns, [module.bedrock_guardrail[0].guardrail_arn]) : var.allowed_guardrail_arns
  enable_xray                      = var.enable_xray
  enable_infrastructure_read_tools = var.enable_infrastructure_read_tools

  create_lambda_invoke_role         = var.create_lambda_invoke_role
  attach_agentcore_managed_policies = var.attach_agentcore_managed_policies
  create_codebuild_role             = var.create_agentcore_runtime
  enable_memory                     = var.create_memory_table
  enable_approvals                  = var.create_approvals_table
  enable_action_tools               = var.enable_action_tools
  cross_account_role_arns           = var.cross_account_role_arns
}

# Conversation memory table for the DynamoDB MemoryProvider (short-term memory).
module "memory" {
  count  = var.create_memory_table ? 1 : 0
  source = "./modules/dynamodb-memory"

  name_prefix = var.resource_prefix
  tags        = local.common_tags
}

# Approval-ticket table for the human-approval workflow (ApprovalGateway).
module "approvals" {
  count  = var.create_approvals_table ? 1 : 0
  source = "./modules/dynamodb-approvals"

  name_prefix = var.resource_prefix
  tags        = local.common_tags
}

# Guide Step 6: ECR repository the AgentCore agent image is pushed to / pulled from.
module "ecr" {
  count  = var.create_ecr ? 1 : 0
  source = "./modules/ecr"

  name_prefix          = var.resource_prefix
  repository_name      = var.ecr_repository_name
  tags                 = local.common_tags
  image_tag_mutability = var.ecr_image_tag_mutability
  scan_on_push         = var.ecr_scan_on_push
  max_image_count      = var.ecr_max_image_count
  untagged_expiry_days = var.ecr_untagged_expiry_days
}

# Guide Step 3: Lambda that fronts the AgentCore runtime (API Gateway proxies to it).
# Requires create_iam_scoped = true so its execution role exists.
module "lambda_invoke" {
  count  = var.create_lambda_invoke ? 1 : 0
  source = "./modules/lambda-invoke"

  name_prefix        = var.resource_prefix
  function_name      = var.lambda_function_name
  role_arn           = module.iam_execution[0].lambda_invoke_role_arn
  tags               = local.common_tags
  runtime            = var.lambda_runtime
  timeout            = var.lambda_timeout
  memory_size        = var.lambda_memory_size
  agent_runtime_arn  = var.agent_runtime_arn
  log_retention_days = var.lambda_log_retention_days
}

# Guide Step 9: REST API (POST /chat) proxying to the invoke Lambda, CORS enabled.
# Requires create_lambda_invoke = true so the integration target exists.
module "api_gateway" {
  count  = var.create_api_gateway ? 1 : 0
  source = "./modules/api-gateway"

  name_prefix       = var.resource_prefix
  api_name          = var.api_name
  tags              = local.common_tags
  lambda_invoke_arn = module.lambda_invoke[0].invoke_arn
  resource_path     = var.api_resource_path
  stage_name        = var.api_stage_name
  cors_allow_origin = var.api_cors_allow_origin
}

# Deliverable 1: Bedrock Guardrail (content filters + denied topics + PII).
# Its ARN is fed into the runtime role's allowed_guardrail_arns above.
module "bedrock_guardrail" {
  count  = var.create_bedrock_guardrail ? 1 : 0
  source = "./modules/bedrock-guardrail"

  name_prefix    = var.resource_prefix
  guardrail_name = var.guardrail_name
  tags           = local.common_tags
  denied_topics  = var.guardrail_denied_topics
  pii_entities   = var.guardrail_pii_entities
  create_version = var.guardrail_create_version
}

# Knowledge base: Bedrock KB backed by an S3 Vectors bucket/index.
module "bedrock_kb" {
  count  = var.create_bedrock_kb ? 1 : 0
  source = "./modules/bedrock-kb"

  create_knowledge_base = var.create_bedrock_kb
  name_prefix           = var.resource_prefix
  tags                  = local.common_tags
  knowledge_bases = {
    for cfg in var.bedrock_kb_configs : cfg.name => cfg
    if try(cfg.enabled, true)
  }
}

# Bedrock Gateway: Bedrock AgentCore gateways backed by optional IAM roles and custom JWT or MCP config.
module "bedrock_gateway" {
  count  = var.create_knowledge_base_gateway ? 1 : 0
  source = "./modules/bedrock-gateway"

  create_knowledge_base_gateway = var.create_knowledge_base_gateway
  name_prefix                   = var.resource_prefix
  tags                          = local.common_tags
  gateways = {
    for cfg in var.bedrock_gateway_configs : cfg.name => cfg
    if try(cfg.enabled, true)
  }
}

# Bedrock Memory: Bedrock AgentCore memory instances backed by optional IAM roles and strategy definitions.
module "bedrock_memory" {
  count  = var.create_knowledge_base_memory ? 1 : 0
  source = "./modules/bedrock-memory"

  create_agentcore_memory = var.create_agentcore_memory
  name_prefix                  = var.resource_prefix
  tags                         = local.common_tags
  memories = {
    for cfg in var.bedrock_memory_configs : cfg.name => cfg
    if try(cfg.enabled, true)
  }
}

# Observability: CloudWatch dashboard + alarms over the runtime's EMF metrics
# (namespace "EPDAR"): requests, latency, tokens, tool calls, guardrail blocks.
module "observability" {
  count  = var.create_observability ? 1 : 0
  source = "./modules/observability"

  name_prefix          = var.resource_prefix
  tags                 = local.common_tags
  alarm_sns_topic_arns = var.observability_alarm_sns_topic_arns
}
