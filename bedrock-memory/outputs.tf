output "memory_ids" {
  description = "IDs of the Bedrock memory resources."
  value       = { for name, memory in aws_bedrockagentcore_memory.this : name => memory.id }
}

output "memory_arns" {
  description = "ARNs of the Bedrock memory resources."
  value       = { for name, memory in aws_bedrockagentcore_memory.this : name => memory.arn }
}

output "memory_names" {
  description = "Names of the Bedrock memory resources."
  value       = { for name, memory in aws_bedrockagentcore_memory.this : name => memory.name }
}

output "memory_role_arns" {
  description = "ARNs of the IAM roles used by the Bedrock memories."
  value       = { for name, role in aws_iam_role.memory : name => role.arn }
}

output "memory_strategy_ids" {
  description = "IDs of the Bedrock memory strategies."
  value       = { for name, strategy in aws_bedrockagentcore_memory_strategy.this : name => strategy.id }
}
