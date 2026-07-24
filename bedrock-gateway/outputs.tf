output "gateway_ids" {
  description = "IDs of the Bedrock gateway resources."
  value       = { for name, gateway in aws_bedrockagentcore_gateway.this : name => gateway.id }
}

output "gateway_arns" {
  description = "ARNs of the Bedrock gateway resources."
  value       = { for name, gateway in aws_bedrockagentcore_gateway.this : name => gateway.arn }
}

output "gateway_names" {
  description = "Names of the Bedrock gateway resources."
  value       = { for name, gateway in aws_bedrockagentcore_gateway.this : name => gateway.name }
}

output "gateway_role_arns" {
  description = "ARNs of the IAM roles used by the Bedrock gateways."
  value       = { for name, role in aws_iam_role.gateway : name => role.arn }
}
