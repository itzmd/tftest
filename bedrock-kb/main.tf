locals {
  knowledge_bases = {
    for name, cfg in var.knowledge_bases : name => merge({
      enabled                  = true
      create_knowledge_base    = true
      kb_name                  = null
      create_s3vector_bucket   = true
      s3vector_bucket_name     = null
      create_s3vector_index    = true
      s3vector_index_name      = null
      data_type                = "float32"
      dimension                = 256
      distance_metric          = "euclidean"
      embedding_model_arn      = null
      embedding_data_type      = "FLOAT32"
      bedrock_role_name        = null
      bedrock_role_policy_name = null
    }, cfg)
  }
}

resource "aws_s3vectors_vector_bucket" "kb" {
  for_each = var.create_knowledge_base ? {
    for name, cfg in local.knowledge_bases : name => cfg
    if try(cfg.enabled, true) && try(cfg.create_knowledge_base, true) && try(cfg.create_s3vector_bucket, true)
  } : {}

  vector_bucket_name = coalesce(try(each.value.s3vector_bucket_name, null), "${var.name_prefix}-kb-store-${each.key}")

  tags = merge(var.tags, {
    Name = coalesce(try(each.value.s3vector_bucket_name, null), "${var.name_prefix}-kb-store-${each.key}")
  })
}

resource "aws_s3vectors_index" "kb" {
  for_each = var.create_knowledge_base ? {
    for name, cfg in local.knowledge_bases : name => cfg
    if try(cfg.enabled, true) && try(cfg.create_knowledge_base, true) && try(cfg.create_s3vector_index, true)
  } : {}

  index_name         = coalesce(try(each.value.s3vector_index_name, null), "${var.name_prefix}-kb-index-${each.key}")
  vector_bucket_name = coalesce(try(each.value.s3vector_bucket_name, null), "${var.name_prefix}-kb-store-${each.key}")

  data_type       = each.value.data_type
  dimension       = each.value.dimension
  distance_metric = each.value.distance_metric

  tags = merge(var.tags, {
    Name = coalesce(try(each.value.s3vector_index_name, null), "${var.name_prefix}-kb-index-${each.key}")
  })
}

resource "aws_iam_role" "bedrock_s3_access" {
  for_each = var.create_knowledge_base ? {
    for name, cfg in local.knowledge_bases : name => cfg
    if try(cfg.enabled, true)
  } : {}

  name = coalesce(try(each.value.bedrock_role_name, null), "${var.name_prefix}-kb-access-role-${each.key}")

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.tags, { Name = coalesce(try(each.value.bedrock_role_name, null), "${var.name_prefix}-kb-access-role-${each.key}") })
}

resource "aws_iam_policy" "bedrock_s3_access" {
  for_each = var.create_knowledge_base ? {
    for name, cfg in local.knowledge_bases : name => cfg
    if try(cfg.enabled, true)
  } : {}

  name        = coalesce(try(each.value.bedrock_role_policy_name, null), "${var.name_prefix}-kb-access-policy-${each.key}")
  description = "Allow Bedrock knowledge base access to the S3 vector store."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ListAndReadBucket"
        Effect = "Allow"
        Action = [
          "s3vectors:GetVectors",
          "s3vectors:PutVectors",
          "s3vectors:DeleteVectors",
          "s3vectors:QueryVectors"
        ]
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bedrock_s3_access" {
  for_each = var.create_knowledge_base ? {
    for name, cfg in local.knowledge_bases : name => cfg
    if try(cfg.enabled, true)
  } : {}

  role       = aws_iam_role.bedrock_s3_access[each.key].name
  policy_arn = aws_iam_policy.bedrock_s3_access[each.key].arn
}

resource "aws_bedrockagent_knowledge_base" "this" {
  for_each = var.create_knowledge_base ? {
    for name, cfg in local.knowledge_bases : name => cfg
    if try(cfg.enabled, true) && try(cfg.create_knowledge_base, true)
  } : {}

  name     = coalesce(try(each.value.kb_name, null), "${var.name_prefix}-bedrock-kb-${each.key}")
  role_arn = aws_iam_role.bedrock_s3_access[each.key].arn

  knowledge_base_configuration {
    vector_knowledge_base_configuration {
      embedding_model_arn = coalesce(try(each.value.embedding_model_arn, null), "arn:aws:bedrock:us-west-2::foundation-model/amazon.titan-embed-text-v2:0")

      embedding_model_configuration {
        bedrock_embedding_model_configuration {
          dimensions          = each.value.dimension
          embedding_data_type = each.value.embedding_data_type
        }
      }
    }

    type = "VECTOR"
  }

  storage_configuration {
    type = "S3_VECTORS"

    s3_vectors_configuration {
      index_arn = aws_s3vectors_index.kb[each.key].index_arn
    }
  }

  tags = merge(var.tags, { Name = coalesce(try(each.value.kb_name, null), "${var.name_prefix}-bedrock-kb-${each.key}") })
}