# -----------------------------------------------------------------------------
# Bedrock Knowledge Base variables
# -----------------------------------------------------------------------------
variable "create_bedrock_kb" {
  description = "Boolean value to determine if a Bedrock Knowledge Base + vector store need to be created or not"
  type        = bool
  default     = false
}

variable "bedrock_kb_create_s3_bucket" {
  description = "Create the S3 bucket used by the Bedrock knowledge base vector store."
  type        = bool
  default     = true
}

variable "bedrock_kb_s3_bucket_name" {
  description = "Explicit S3 bucket name for the Bedrock knowledge base vector store. Null = derive from resource_prefix."
  type        = string
  default     = null
}

variable "bedrock_kb_index_name" {
  description = "Explicit name for the S3 Vectors index. Null = derive from resource_prefix."
  type        = string
  default     = null
}

variable "bedrock_kb_data_type" {
  description = "Data type stored in the S3 Vectors index."
  type        = string
  default     = "float32"
}

variable "bedrock_kb_dimension" {
  description = "Embedding dimension size for the S3 Vectors index."
  type        = number
  default     = 256
}

variable "bedrock_kb_distance_metric" {
  description = "Distance metric used by the S3 Vectors index."
  type        = string
  default     = "euclidean"
}

variable "bedrock_kb_embedding_model_arn" {
  description = "ARN of the Bedrock embedding model used by the knowledge base."
  type        = string
  default     = "arn:aws:bedrock:us-west-2::foundation-model/amazon.titan-embed-text-v2:0"
}

variable "bedrock_kb_embedding_data_type" {
  description = "Embedding data type for the Bedrock embedding model configuration."
  type        = string
  default     = "FLOAT32"
}

# =============================================================================
# Core placement variables (same convention as the serverless repo)
# =============================================================================
variable "location" {
  description = "Location value for mapping resources. Possible values: us"
  type        = string
  default     = "us"
}

variable "environment" {
  description = "Environment value for mapping resources. POC currently supports: dev"
  type        = string
  default     = "dev"
}

variable "resource_prefix" {
  description = "Prefix for the resource names. No special characters except '_' and '-', max 20 chars."
  type        = string
}

# =============================================================================
# Feature flags - each AI capability is gated by a boolean, matching the
# `count = var.<flag> ? 1 : 0` pattern used across the serverless repo.
# Product teams enable only what they need via input-json/*.json.
# =============================================================================
variable "create_iam_scoped" {
  description = "Boolean value to determine if the scoped Bedrock/AgentCore IAM role(s) need to be created or not"
  type        = bool
  default     = false
}

variable "create_ecr" {
  description = "Boolean value to determine if the ECR repository for the AgentCore agent image need to be created or not"
  type        = bool
  default     = false
}

variable "create_lambda_invoke" {
  description = "Boolean value to determine if the AgentCore invoke Lambda function need to be created or not"
  type        = bool
  default     = false
}

variable "create_api_gateway" {
  description = "Boolean value to determine if the REST API Gateway fronting the invoke Lambda need to be created or not"
  type        = bool
  default     = false
}

variable "create_bedrock_agent" {
  description = "Boolean value to determine if a Bedrock Agent (AgentCore) need to be created or not"
  type        = bool
  default     = false
}



variable "create_bedrock_guardrail" {
  description = "Boolean value to determine if a Bedrock Guardrail need to be created or not"
  type        = bool
  default     = false
}

variable "create_observability" {
  description = "Boolean value to determine if model-invocation logging, CloudWatch and cost guardrails need to be created or not"
  type        = bool
  default     = false
}

variable "observability_alarm_sns_topic_arns" {
  description = "Optional SNS topic ARNs notified when observability alarms fire (empty = no notification action)"
  type        = list(string)
  default     = []
}

variable "create_agentcore_runtime" {
  description = "Boolean value to determine if the AgentCore runtime is deployed via the starter toolkit (Option A). When true, a CodeBuild execution role is also created for the toolkit's container build."
  type        = bool
  default     = false
}

# =============================================================================
# Scoping inputs for the iam-execution module (deliverable 3). Defaults are
# permissive for POC; scope allowed_model_arns / allowed_ecr_repository_arns
# down per consumer via input-json for production.
# =============================================================================
variable "allowed_model_arns" {
  description = "Foundation/inference model ARNs the AgentCore runtime may invoke ('*' = any enabled model)"
  type        = list(string)
  default     = ["*"]
}

variable "allowed_ecr_repository_arns" {
  description = "ECR repository ARNs the runtime may pull agent images from (null = all repos in this account/region)"
  type        = list(string)
  default     = null
}

variable "allowed_guardrail_arns" {
  description = "Optional Bedrock Guardrail ARNs the runtime may apply (empty = none)"
  type        = list(string)
  default     = []
}

variable "enable_xray" {
  description = "Grant X-Ray tracing permissions to the AgentCore runtime role"
  type        = bool
  default     = true
}

variable "enable_infrastructure_read_tools" {
  description = "Grant the runtime role read-only infrastructure describe permissions (EC2/ECS/EKS/ALB/RDS/CloudWatch) for the Infrastructure agent"
  type        = bool
  default     = false
}

variable "create_memory_table" {
  description = "Create the DynamoDB conversation-memory table and grant the runtime role access to it"
  type        = bool
  default     = false
}

variable "create_approvals_table" {
  description = "Create the DynamoDB approvals table and grant the runtime role access to it (human-approval workflow)"
  type        = bool
  default     = false
}

variable "enable_action_tools" {
  description = "Grant the runtime role permissions for approval-gated action (mutating) tools, e.g. ec2:CreateTags"
  type        = bool
  default     = false
}

variable "cross_account_role_arns" {
  description = "Cross-account read-only role ARNs the runtime may assume for multi-account inspection. Empty = single-account (ambient credentials)."
  type        = list(string)
  default     = []
}

variable "knowledge_base_arns" {
  description = "Bedrock Knowledge Base ARNs the runtime may call bedrock:Retrieve on (RAG). Empty = no KB access."
  type        = list(string)
  default     = []
}

variable "knowledge_base_id" {
  description = "Bedrock Knowledge Base id injected into the runtime (ECAP_KNOWLEDGE_BASE_ID) to enable vector RAG. Empty = local fallback RAG."
  type        = string
  default     = ""
}

variable "create_lambda_invoke_role" {
  description = "Create the execution role for the AgentCore invoke Lambda (setup guide Step 5)"
  type        = bool
  default     = true
}

variable "attach_agentcore_managed_policies" {
  description = "Compatibility toggle: attach the setup guide's AWS-managed AgentCore policies to the runtime role (false = least-privilege)"
  type        = bool
  default     = false
}

# =============================================================================
# Inputs for the ecr module (setup guide Step 6).
# =============================================================================
variable "ecr_repository_name" {
  description = "Explicit ECR repository name. Null = derive as '<resource_prefix>-agentcore'."
  type        = string
  default     = null
}

variable "ecr_image_tag_mutability" {
  description = "ECR tag mutability: IMMUTABLE (recommended) or MUTABLE."
  type        = string
  default     = "IMMUTABLE"
}

variable "ecr_scan_on_push" {
  description = "Enable ECR basic vulnerability scanning on image push."
  type        = bool
  default     = true
}

variable "ecr_max_image_count" {
  description = "Keep only the most recent N tagged images in ECR."
  type        = number
  default     = 10
}

variable "ecr_untagged_expiry_days" {
  description = "Expire untagged ECR images older than this many days."
  type        = number
  default     = 7
}

# =============================================================================
# Inputs for the lambda-invoke module (setup guide Step 3).
# =============================================================================
variable "lambda_function_name" {
  description = "Explicit invoke-Lambda name. Null = derive as '<resource_prefix>-agentcore-invoke'."
  type        = string
  default     = null
}

variable "lambda_runtime" {
  description = "Python runtime for the invoke Lambda."
  type        = string
  default     = "python3.12"
}

variable "lambda_timeout" {
  description = "Invoke-Lambda timeout in seconds."
  type        = number
  default     = 60
}

variable "lambda_memory_size" {
  description = "Invoke-Lambda memory in MB."
  type        = number
  default     = 256
}

variable "agent_runtime_arn" {
  description = "AgentCore runtime ARN the invoke Lambda calls (AGENT_RUNTIME_ARN). Empty until the runtime is deployed by the toolkit."
  type        = string
  default     = ""
}

variable "lambda_log_retention_days" {
  description = "CloudWatch log retention (days) for the invoke Lambda."
  type        = number
  default     = 14
}

# =============================================================================
# Inputs for the api-gateway module (setup guide Step 9).
# =============================================================================
variable "api_name" {
  description = "Explicit REST API name. Null = derive as '<resource_prefix>-agentcore-api'."
  type        = string
  default     = null
}

variable "api_resource_path" {
  description = "Path part that accepts the chat request (POST /<path>)."
  type        = string
  default     = "chat"
}

variable "api_stage_name" {
  description = "API Gateway deployment stage name (dev/stage/prod)."
  type        = string
  default     = "dev"
}

variable "api_cors_allow_origin" {
  description = "Access-Control-Allow-Origin for the API. '*' for POC; lock down for production."
  type        = string
  default     = "*"
}

# =============================================================================
# Inputs for the bedrock-guardrail module (deliverable 1).
# =============================================================================
variable "guardrail_name" {
  description = "Explicit guardrail name. Null = derive as '<resource_prefix>-guardrail'."
  type        = string
  default     = null
}

variable "guardrail_denied_topics" {
  description = "Topics the agent must refuse (name, definition, optional examples)."
  type = list(object({
    name       = string
    definition = string
    examples   = optional(list(string), [])
  }))
  default = []
}

variable "guardrail_pii_entities" {
  description = "PII entity types to protect and the action (BLOCK/ANONYMIZE). Empty = module defaults."
  type = list(object({
    type   = string
    action = string
  }))
  default = null
}

variable "guardrail_create_version" {
  description = "Publish an immutable version of the guardrail in addition to DRAFT."
  type        = bool
  default     = true
}

# =============================================================================
# Standard tagging variables (identical to the serverless coding standard).
# These are populated by terraform_run.sh from LeanIX using app_id.
# =============================================================================
variable "app_id" {
  description = "Application ID of the instance"
  type        = string
}

variable "app_name" {
  description = "Application name of the instance"
  type        = string
  default     = ""
}

variable "billing_owner" {
  description = "WWID of the business owner"
  type        = string
  default     = ""
}

variable "tech_owner" {
  description = "WWID of the application owner"
  type        = string
  default     = ""
}

variable "bu" {
  description = "Business unit"
  type        = string
  default     = ""
}

variable "bc" {
  description = "Billing Code"
  type        = string
  default     = ""
}

variable "rc" {
  description = "Response Code"
  type        = string
  default     = ""
}

variable "deptcode" {
  description = "Department Code"
  type        = string
  default     = ""
}

variable "project" {
  description = "Code of the project the instance will be used for"
  type        = string
}

variable "purpose" {
  description = "Purpose of the instance"
  type        = string
  default     = ""
}

variable "responsible" {
  description = "Contact point for infrastructure updates, sizing and decommission"
  type        = string
  default     = ""
}

variable "tf_lifecycle" {
  description = "Directory name for storing Terraform Lifecycle"
  type        = string
  default     = "ai-infra"
}

# =============================================================================
# Provisioning map. Kept in the same nested location -> environment -> {...}
# shape as the serverless repo so additional environments can be added later
# without changing any lookups. For the POC only a single account is onboarded.
# =============================================================================
variable "aws_provision_map" {
  description = "Infrastructure provisioning map for AWS"
  type        = map(map(map(any)))
  default = {
    us = {
      "dev" = {
        "account"    = "320815835048"
        "region"     = "us-east-1"
        "env_suffix" = "dev"
        "env_tag"    = "dev"
      }
    }
  }
}

# =============================================================================
# Common tags applied (via merge) to every resource. Adds Provisioner/ManagedBy
# so Terraform-managed resources can be distinguished from the ones people
# created by hand in this shared POC account.
# =============================================================================
locals {
  common_tags = {
    appid        = var.app_id
    appname      = var.app_name
    billingowner = var.billing_owner
    techowner    = var.tech_owner
    bu           = var.bu
    bc           = var.bc
    rc           = var.rc
    deptcode     = var.deptcode
    project      = var.project
    purpose      = var.purpose
    responsible  = var.responsible
    tf_state_dir = var.tf_lifecycle
    environment  = lookup(lookup(lookup(var.aws_provision_map, var.location), var.environment), "env_tag")
    Provisioner  = "terraform"
    ManagedBy    = "terraform"
    Repo         = "techit-epic-epdar-enterprise-ai-platform"
    datedeployed = formatdate("DD MMM YYYY hh:mm ZZZ", timestamp())
  }
}
