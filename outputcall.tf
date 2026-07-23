# -----------------------------------------------------------------------------
# Bedrock Knowledge Base outputs
# -----------------------------------------------------------------------------
output "bedrock_kb_vector_bucket_name" {
  description = "S3 Vectors bucket name used by the Bedrock Knowledge Base"
  value       = var.create_bedrock_kb ? module.bedrock_kb[0].s3_bucket_id : null
}

output "bedrock_kb_vector_bucket_arn" {
  description = "ARN of the S3 Vectors bucket used by the Bedrock Knowledge Base"
  value       = var.create_bedrock_kb ? module.bedrock_kb[0].s3_bucket_arn : null
}

output "bedrock_kb_index_name" {
  description = "Name of the S3 Vectors index backing the Bedrock Knowledge Base"
  value       = var.create_bedrock_kb ? module.bedrock_kb[0].index_name : null
}

output "bedrock_kb_index_arn" {
  description = "ARN of the S3 Vectors index backing the Bedrock Knowledge Base"
  value       = var.create_bedrock_kb ? module.bedrock_kb[0].index_arn : null
}

output "bedrock_kb_name" {
  description = "Bedrock Knowledge Base name"
  value       = var.create_bedrock_kb ? module.bedrock_kb[0].knowledge_base_name : null
}

output "bedrock_kb_arn" {
  description = "ARN of the Bedrock Knowledge Base"
  value       = var.create_bedrock_kb ? module.bedrock_kb[0].knowledge_base_arn : null
}

output "bedrock_kb_iam_role_arn" {
  description = "ARN of the IAM role granted to Bedrock for S3 Vectors access"
  value       = var.create_bedrock_kb ? module.bedrock_kb[0].bedrock_s3_role_arn : null
}
