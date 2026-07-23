locals {
  kb_name             = coalesce(var.kb_name, "${var.name_prefix}-bedrock-kb")
  vector_bucket_name  = coalesce(var.s3_bucket_name, "${var.name_prefix}-kb-store")
  index_name          = coalesce(var.index_name, "${var.name_prefix}-kb-index")
  bedrock_role_name   = coalesce(var.bedrock_role_name, "${var.name_prefix}-kb-access-role")
  bedrock_policy_name = coalesce(var.bedrock_role_policy_name, "${var.name_prefix}-kb-access-policy")
  s3_bucket_arn       = "arn:aws:s3:::${local.vector_bucket_name}"
}

resource "aws_s3vectors_vector_bucket" "kb" {
  count = var.enabled && var.create_s3_bucket ? 1 : 0

  vector_bucket_name = local.vector_bucket_name

  tags = merge(var.tags, {
    Name = local.vector_bucket_name
  })
}

resource "aws_s3vectors_index" "kb" {
  count = var.enabled ? 1 : 0

  index_name         = local.index_name
  vector_bucket_name = local.vector_bucket_name

  data_type       = var.data_type
  dimension       = var.dimension
  distance_metric = var.distance_metric

  tags = merge(var.tags, {
    Name = local.index_name
  })
}

resource "aws_iam_role" "bedrock_s3_access" {
  count = var.enabled ? 1 : 0

  name = local.bedrock_role_name

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

  tags = merge(var.tags, { Name = local.bedrock_role_name })
}

resource "aws_iam_policy" "bedrock_s3_access" {
  count = var.enabled ? 1 : 0

  name        = local.bedrock_policy_name
  description = "Allow Bedrock knowledge base access to the S3 vector store."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "ListAndReadBucket"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          local.s3_bucket_arn,
          "${local.s3_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bedrock_s3_access" {
  count = var.enabled ? 1 : 0

  role       = aws_iam_role.bedrock_s3_access[0].name
  policy_arn = aws_iam_policy.bedrock_s3_access[0].arn
}

resource "aws_bedrockagent_knowledge_base" "this" {
  count = var.enabled ? 1 : 0

  name     = local.kb_name
  role_arn = aws_iam_role.bedrock_s3_access[0].arn

  knowledge_base_configuration {
    vector_knowledge_base_configuration {
      embedding_model_arn = var.embedding_model_arn

      embedding_model_configuration {
        bedrock_embedding_model_configuration {
          dimensions          = var.dimension
          embedding_data_type = var.embedding_data_type
        }
      }
    }

    type = "VECTOR"
  }

  storage_configuration {
    type = "S3_VECTORS"

    s3_vectors_configuration {
      index_arn = aws_s3vectors_index.kb[0].index_arn
    }
  }

  tags = merge(var.tags, { Name = local.kb_name })
}
