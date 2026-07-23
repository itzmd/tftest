locals {
  // Networking
  

  vpcenv = upper(var.environment.environment_classification) == "PRODUCTION" ? "prod" : upper(var.environment.environment_classification) == "MANAGEMENT" ? "mgmt" : upper(var.environment.environment_classification) == "SECURE PRODUCTION" ? "ig" : "nprod"

  // For Providers Do Not Change
  arn_prod  = "arn:aws:iam::224402104779:role/terraform-iaac-iam-role"
  arn_nprod = "arn:aws:iam::665235025580:role/terraform-iaac-iam-role"
  arn_sprod = "arn:aws:iam::331736340972:role/terraform-iaac-iam-role"
  arn_mgmt  = null
  role_arn  = upper(var.environment.environment_classification) == "PRODUCTION" ? local.arn_prod : upper(var.environment.environment_classification) == "MANAGEMENT" ? local.arn_mgmt : upper(var.environment.environment_classification) == "SECURE PRODUCTION" ? local.arn_sprod : local.arn_nprod

  // S3 Bucket Logging
  logging_bucket_name = upper(var.environment.environment_classification) == "PRODUCTION" ? "services-logs-prod-bucket" : upper(var.environment.environment_classification) == "MANAGEMENT" ? "services-logs-mgmt-bucket" : upper(var.environment.environment_classification) == "SECURE PRODUCTION" ? "services-logs-int-bucket" : "services-logs-nprod-bucket"

  }

provider "aws" {
  
  region  = "us-east-1"
  assume_role {
    role_arn = local.role_arn
  }
}
