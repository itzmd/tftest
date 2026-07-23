"create_bedrock_kb": true,
  "bedrock_kb_create_s3_bucket": true,
  "bedrock_kb_s3_bucket_name": null,
  "bedrock_kb_index_name": null,
  "bedrock_kb_data_type": "float32",
  "bedrock_kb_dimension": 256,
  "bedrock_kb_distance_metric": "euclidean",
  "bedrock_kb_embedding_model_arn": "arn:aws:bedrock:us-west-2::foundation-model/amazon.titan-embed-text-v2:0",
  "bedrock_kb_embedding_data_type": "FLOAT32"

output "vector_bucket_name" {
  description = "Name of the S3 Vectors bucket used by the knowledge base."
  value       = local.vector_bucket_name
}

output "vector_bucket_arn" {
  description = "ARN of the S3 Vectors bucket used by the knowledge base."
  value       = var.enabled ? "arn:aws:s3:::${local.vector_bucket_name}" : null
}

output "index_name" {
  description = "Name of the S3 Vectors index."
  value       = var.enabled ? aws_s3vectors_index.kb[0].index_name : null
}

output "index_arn" {
  description = "ARN of the S3 Vectors index."
  value       = var.enabled ? aws_s3vectors_index.kb[0].index_arn : null
}

output "knowledge_base_id" {
  description = "ID of the Bedrock knowledge base."
  value       = var.enabled ? aws_bedrockagent_knowledge_base.this[0].id : null
}

output "knowledge_base_arn" {
  description = "ARN of the Bedrock knowledge base."
  value       = var.enabled ? aws_bedrockagent_knowledge_base.this[0].arn : null
}

output "knowledge_base_name" {
  description = "Name of the Bedrock knowledge base."
  value       = var.enabled ? aws_bedrockagent_knowledge_base.this[0].name : null
}


output "bedrock_s3_role_arn" {
  description = "ARN of the IAM role granted to Bedrock for S3 access."
  value       = var.enabled ? aws_iam_role.bedrock_s3_access[0].arn : null
}
