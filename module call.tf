module "bedrock_kb" {
  count  = var.create_bedrock_kb ? 1 : 0
  source = "./modules/bedrock-kb"

  enabled               = var.create_bedrock_kb
  name_prefix           = var.resource_prefix
  tags                  = local.common_tags
  create_s3_bucket      = var.bedrock_kb_create_s3_bucket
  s3_bucket_name        = var.bedrock_kb_s3_bucket_name
  index_name            = var.bedrock_kb_index_name
  data_type             = var.bedrock_kb_data_type
  dimension             = var.bedrock_kb_dimension
  distance_metric       = var.bedrock_kb_distance_metric
  embedding_model_arn   = var.bedrock_kb_embedding_model_arn
  embedding_data_type   = var.bedrock_kb_embedding_data_type
}
