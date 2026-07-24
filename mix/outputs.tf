# Baseline outputs. Feature-specific outputs are added alongside their modules
# in later steps, using the same `var.<flag> ? resource[0].x : null` convention
# as the serverless repo.
output "account_id" {
  description = "AWS account id Terraform provisioned into"
  value       = data.aws_caller_identity.current.account_id
}

output "region" {
  description = "AWS region Terraform provisioned into"
  value       = data.aws_region.current.name
}

# Guide Step 6: ECR repository outputs (null unless create_ecr = true)
output "ecr_repository_url" {
  description = "ECR repository URI - pass to `agentcore configure` so the toolkit reuses it"
  value       = var.create_ecr ? module.ecr[0].repository_url : null
}

output "ecr_repository_arn" {
  description = "ECR repository ARN - feed to allowed_ecr_repository_arns to scope runtime pull access"
  value       = var.create_ecr ? module.ecr[0].repository_arn : null
}

# Guide Step 3: invoke Lambda outputs (null unless create_lambda_invoke = true)
output "invoke_lambda_function_name" {
  description = "Name of the AgentCore invoke Lambda function"
  value       = var.create_lambda_invoke ? module.lambda_invoke[0].function_name : null
}

output "invoke_lambda_invoke_arn" {
  description = "Invoke ARN of the Lambda - used by the API Gateway proxy integration"
  value       = var.create_lambda_invoke ? module.lambda_invoke[0].invoke_arn : null
}

# Guide Step 9: API Gateway outputs (null unless create_api_gateway = true)
output "api_invoke_url" {
  description = "Public POST URL for the chat endpoint (the API URL to hand to consumers)"
  value       = var.create_api_gateway ? module.api_gateway[0].invoke_url : null
}

output "api_execution_arn" {
  description = "API Gateway execution ARN"
  value       = var.create_api_gateway ? module.api_gateway[0].execution_arn : null
}

# Deliverable 1: Bedrock Guardrail outputs (null unless create_bedrock_guardrail = true)
output "guardrail_arn" {
  description = "ARN of the Bedrock Guardrail"
  value       = var.create_bedrock_guardrail ? module.bedrock_guardrail[0].guardrail_arn : null
}

output "guardrail_version" {
  description = "Published Bedrock Guardrail version"
  value       = var.create_bedrock_guardrail ? module.bedrock_guardrail[0].guardrail_version : null
}

# Deliverable 3: execution role outputs (null unless create_iam_scoped = true)
output "agentcore_runtime_role_arn" {
  description = "ARN of the least-privilege AgentCore runtime execution role"
  value       = var.create_iam_scoped ? module.iam_execution[0].agentcore_runtime_role_arn : null
}

output "agentcore_runtime_role_name" {
  description = "Name of the least-privilege AgentCore runtime execution role"
  value       = var.create_iam_scoped ? module.iam_execution[0].agentcore_runtime_role_name : null
}

output "lambda_invoke_role_arn" {
  description = "ARN of the AgentCore invoke Lambda execution role"
  value       = var.create_iam_scoped ? module.iam_execution[0].lambda_invoke_role_arn : null
}

output "lambda_invoke_role_name" {
  description = "Name of the AgentCore invoke Lambda execution role"
  value       = var.create_iam_scoped ? module.iam_execution[0].lambda_invoke_role_name : null
}

output "codebuild_role_arn" {
  description = "ARN of the CodeBuild execution role for AgentCore toolkit builds (null unless create_agentcore_runtime = true)"
  value       = var.create_iam_scoped && var.create_agentcore_runtime ? module.iam_execution[0].codebuild_role_arn : null
}

output "memory_table_name" {
  description = "Conversation memory DynamoDB table name (null unless create_memory_table = true)"
  value       = var.create_memory_table ? module.memory[0].table_name : null
}

output "approvals_table_name" {
  description = "Approvals DynamoDB table name (null unless create_approvals_table = true)"
  value       = var.create_approvals_table ? module.approvals[0].table_name : null
}

output "observability_dashboard_name" {
  description = "CloudWatch dashboard name (null unless create_observability = true)"
  value       = var.create_observability ? module.observability[0].dashboard_name : null
}
# -----------------------------------------------------------------------------
# Bedrock Knowledge Base outputs
# -----------------------------------------------------------------------------
#output "bedrock_kb_vector_bucket_name" {
# description = "S3 Vectors bucket name used by the Bedrock Knowledge Base"
#value       = var.create_bedrock_kb ? module.bedrock_kb[0].s3_bucket_id : null
#}

#output "bedrock_kb_vector_bucket_arn" {
# description = "ARN of the S3 Vectors bucket used by the Bedrock Knowledge Base"
#value       = var.create_bedrock_kb ? module.bedrock_kb[0].s3_bucket_arn : null
#}

output "bedrock_kb_index_names" {
  description = "Names of the S3 Vectors indexes backing the Bedrock knowledge bases"
  value       = var.create_bedrock_kb ? module.bedrock_kb[0].index_names : {}
}

output "bedrock_kb_index_arns" {
  description = "ARNs of the S3 Vectors indexes backing the Bedrock knowledge bases"
  value       = var.create_bedrock_kb ? module.bedrock_kb[0].index_arns : {}
}

output "bedrock_kb_names" {
  description = "Bedrock knowledge base names"
  value       = var.create_bedrock_kb ? module.bedrock_kb[0].knowledge_base_names : {}
}

output "bedrock_kb_arns" {
  description = "ARNs of the Bedrock knowledge bases"
  value       = var.create_bedrock_kb ? module.bedrock_kb[0].knowledge_base_arns : {}
}

output "bedrock_kb_iam_role_arns" {
  description = "ARNs of the IAM roles granted to Bedrock for S3 Vectors access"
  value       = var.create_bedrock_kb ? module.bedrock_kb[0].bedrock_s3_role_arns : {}
}

output "bedrock_kb_name" {
  description = "Name of the first Bedrock knowledge base for backwards compatibility"
  value       = var.create_bedrock_kb ? module.bedrock_kb[0].knowledge_base_name : null
}

output "bedrock_kb_arn" {
  description = "ARN of the first Bedrock knowledge base for backwards compatibility"
  value       = var.create_bedrock_kb ? module.bedrock_kb[0].knowledge_base_arn : null
}

output "bedrock_kb_iam_role_arn" {
  description = "ARN of the first IAM role granted to Bedrock for S3 Vectors access"
  value       = var.create_bedrock_kb ? module.bedrock_kb[0].bedrock_s3_role_arn : null
}

output "bedrock_gateway_ids" {
  description = "IDs of the Bedrock gateways"
  value       = var.create_knowledge_base_gateway ? module.bedrock_gateway[0].gateway_ids : {}
}

output "bedrock_gateway_arns" {
  description = "ARNs of the Bedrock gateways"
  value       = var.create_knowledge_base_gateway ? module.bedrock_gateway[0].gateway_arns : {}
}

output "bedrock_gateway_names" {
  description = "Names of the Bedrock gateways"
  value       = var.create_knowledge_base_gateway ? module.bedrock_gateway[0].gateway_names : {}
}

output "bedrock_gateway_role_arns" {
  description = "ARNs of the IAM roles used by the Bedrock gateways"
  value       = var.create_knowledge_base_gateway ? module.bedrock_gateway[0].gateway_role_arns : {}
}