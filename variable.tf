# =============================================================================
# Module: bedrock-kb
#
# Provisions an Amazon Bedrock agent knowledge base backed by an S3 Vectors bucket
# and index, with optional API Gateway wiring.
# =============================================================================

variable "enabled" {
  description = "Whether to create the Bedrock Knowledge Base, S3 Vectors bucket/index, and optional gateway."
  type        = bool
  default     = false
}

variable "name_prefix" {
  description = "Prefix for resource names, usually the resource_prefix from the root module."
  type        = string
}

variable "kb_name" {
  description = "Explicit Bedrock knowledge base name. Null = derive from name_prefix."
  type        = string
  default     = null
}

variable "description" {
  description = "Description for the knowledge base."
  type        = string
  default     = "Bedrock knowledge base backed by S3 Vectors."
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "create_s3_bucket" {
  description = "Whether the module should create the S3 Vectors bucket."
  type        = bool
  default     = true
}

variable "s3_bucket_name" {
  description = "Explicit vector bucket name. Null = derive from name_prefix when create_s3_bucket is true."
  type        = string
  default     = null
}

variable "index_name" {
  description = "Explicit S3 Vectors index name. Null = derive from name_prefix."
  type        = string
  default     = null
}

variable "data_type" {
  description = "Data type stored in the vectors index."
  type        = string
  default     = "float32"
}

variable "dimension" {
  description = "Embedding dimension size for the S3 Vectors index."
  type        = number
  default     = 256
}

variable "distance_metric" {
  description = "Distance metric used by the S3 Vectors index."
  type        = string
  default     = "euclidean"
}

variable "embedding_data_type" {
  description = "Embedding data type for the Bedrock embedding model configuration."
  type        = string
  default     = "FLOAT32"
}

variable "embedding_model_arn" {
  description = "ARN of the Bedrock embedding model used by the knowledge base."
  type        = string
  default     = "arn:aws:bedrock:us-west-2::foundation-model/amazon.titan-embed-text-v2:0"
}


variable "bedrock_role_name" {
  description = "Explicit IAM role name for Bedrock to access the S3 Vectors store. Null = derive from name_prefix."
  type        = string
  default     = null
}

variable "bedrock_role_policy_name" {
  description = "Explicit IAM role policy name for Bedrock S3 access. Null = derive from the role name."
  type        = string
  default     = null
}
