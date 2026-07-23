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
