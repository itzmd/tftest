output "knowledge_bases" {
  description = "Detailed outputs for all Bedrock knowledge base instances created by the module."
  value = {
    for name, cfg in local.knowledge_bases : name => {
      vector_bucket_name  = try(aws_s3vectors_vector_bucket.kb[name].vector_bucket_name, null)
      index_name          = try(aws_s3vectors_index.kb[name].index_name, null)
      index_arn           = try(aws_s3vectors_index.kb[name].index_arn, null)
      knowledge_base_id   = try(aws_bedrockagent_knowledge_base.this[name].id, null)
      knowledge_base_arn  = try(aws_bedrockagent_knowledge_base.this[name].arn, null)
      knowledge_base_name = try(aws_bedrockagent_knowledge_base.this[name].name, null)
      bedrock_s3_role_arn = try(aws_iam_role.bedrock_s3_access[name].arn, null)
    }
  }
}

output "vector_bucket_names" {
  description = "Names of the S3 Vectors buckets used by the knowledge bases."
  value       = { for name, bucket in aws_s3vectors_vector_bucket.kb : name => bucket.vector_bucket_name }
}

output "vector_bucket_arns" {
  description = "ARNs of the S3 Vectors buckets used by the knowledge bases."
  value       = { for name, bucket in aws_s3vectors_vector_bucket.kb : name => "arn:aws:s3:::${bucket.vector_bucket_name}" }
}

output "index_names" {
  description = "Names of the S3 Vectors indexes."
  value       = { for name, index in aws_s3vectors_index.kb : name => index.index_name }
}

output "index_arns" {
  description = "ARNs of the S3 Vectors indexes."
  value       = { for name, index in aws_s3vectors_index.kb : name => index.index_arn }
}

output "knowledge_base_ids" {
  description = "IDs of the Bedrock knowledge bases."
  value       = { for name, kb in aws_bedrockagent_knowledge_base.this : name => kb.id }
}

output "knowledge_base_arns" {
  description = "ARNs of the Bedrock knowledge bases."
  value       = { for name, kb in aws_bedrockagent_knowledge_base.this : name => kb.arn }
}

output "knowledge_base_names" {
  description = "Names of the Bedrock knowledge bases."
  value       = { for name, kb in aws_bedrockagent_knowledge_base.this : name => kb.name }
}

output "bedrock_s3_role_arns" {
  description = "ARNs of the IAM roles granted to Bedrock for S3 access."
  value       = { for name, role in aws_iam_role.bedrock_s3_access : name => role.arn }
}

output "knowledge_base_name" {
  description = "Name of the first Bedrock knowledge base for backwards compatibility."
  value       = var.enabled && length(aws_bedrockagent_knowledge_base.this) > 0 ? values(aws_bedrockagent_knowledge_base.this)[0].name : null
}

output "knowledge_base_arn" {
  description = "ARN of the first Bedrock knowledge base for backwards compatibility."
  value       = var.enabled && length(aws_bedrockagent_knowledge_base.this) > 0 ? values(aws_bedrockagent_knowledge_base.this)[0].arn : null
}

output "bedrock_s3_role_arn" {
  description = "ARN of the first IAM role granted to Bedrock for S3 access for backwards compatibility."
  value       = var.enabled && length(aws_iam_role.bedrock_s3_access) > 0 ? values(aws_iam_role.bedrock_s3_access)[0].arn : null
}