locals {
  memory_configs = {
    for name, cfg in var.memories : name => merge({
      enabled                 = true
      create_memory           = true
      memory_name             = null
      event_expiry_duration  = 30
      role_name               = null
      role_arn                = null
      strategies              = []
    }, cfg)
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["bedrock-agentcore.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "memory" {
  for_each = var.create_agentcore_memory ? {
    for name, cfg in local.memory_configs : name => cfg
    if try(cfg.enabled, true) && try(cfg.create_memory, true)
  } : {}

  name               = coalesce(try(each.value.role_name, null), "${var.name_prefix}-bedrock-memory-${each.key}")
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = merge(var.tags, {
    Name = coalesce(try(each.value.role_name, null), "${var.name_prefix}-bedrock-memory-${each.key}")
  })
}

resource "aws_iam_role_policy_attachment" "memory" {
  for_each = var.create_agentcore_memory ? {
    for name, cfg in local.memory_configs : name => cfg
    if try(cfg.enabled, true) && try(cfg.create_memory, true)
  } : {}

  role       = aws_iam_role.memory[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonBedrockAgentCoreMemoryBedrockModelInferenceExecutionRolePolicy"
}

resource "aws_bedrockagentcore_memory" "this" {
  for_each = var.create_agentcore_memory ? {
    for name, cfg in local.memory_configs : name => cfg
    if try(cfg.enabled, true) && try(cfg.create_memory, true)
  } : {}

  name                  = coalesce(try(each.value.memory_name, null), "${var.name_prefix}-memory-${each.key}")
  event_expiry_duration = each.value.event_expiry_duration
  memory_execution_role_arn = coalesce(try(each.value.role_arn, null), aws_iam_role.memory[each.key].arn)
}

resource "aws_bedrockagentcore_memory_strategy" "this" {
  for_each = var.create_agentcore_memory ? {
    for name, cfg in local.memory_configs : name => cfg
    if try(cfg.enabled, true) && try(cfg.create_memory, true)
  } : {}

  for_each = {
    for entry in flatten([
      for name, cfg in local.memory_configs : [
        for strategy in try(cfg.strategies, []) : merge(strategy, { memory_key = name })
      ]
    ]) : "${entry.memory_key}:${entry.name}" => entry
  }

  name        = each.value.name
  memory_id   = aws_bedrockagentcore_memory.this[each.value.memory_key].id
  type        = each.value.type
  description = each.value.description
  namespaces  = each.value.namespaces

  dynamic "configuration" {
    for_each = try(each.value.configuration, null) != null ? [each.value.configuration] : []
    content {
      type = configuration.value.type

      dynamic "consolidation" {
        for_each = try(configuration.value.consolidation, null) != null ? [configuration.value.consolidation] : []
        content {
          append_to_prompt = consolidation.value.append_to_prompt
          model_id         = consolidation.value.model_id
        }
      }

      dynamic "extraction" {
        for_each = try(configuration.value.extraction, null) != null ? [configuration.value.extraction] : []
        content {
          append_to_prompt = extraction.value.append_to_prompt
          model_id         = extraction.value.model_id
        }
      }
    }
  }
}
