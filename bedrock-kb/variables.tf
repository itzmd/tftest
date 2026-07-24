variable "create_knowledge_base" {
  description = "Whether the module should manage any Bedrock knowledge base resources."
  type        = bool
  default     = true
}

variable "name_prefix" {
  description = "Prefix for resource names, usually the resource_prefix from the root module."
  type        = string
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "knowledge_bases" {
  description = "Map of Bedrock knowledge base configurations to create."
  type = map(object({
    enabled                   = optional(bool, true)
    create_knowledge_base     = optional(bool, true)
    kb_name                   = optional(string, null)
    create_s3vector_bucket    = optional(bool, true)
    s3vector_bucket_name      = optional(string, null)
    create_s3vector_index     = optional(bool, true)
    s3vector_index_name       = optional(string, null)
    data_type                 = optional(string, "float32")
    dimension                 = optional(number, 256)
    distance_metric           = optional(string, "euclidean")
    embedding_model_arn       = optional(string, null)
    embedding_data_type       = optional(string, "FLOAT32")
    bedrock_role_name         = optional(string, null)
    bedrock_role_policy_name  = optional(string, null)
  }))
  default = {}
}