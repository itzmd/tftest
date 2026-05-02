terraform {
  backend "s3" {
    bucket = "xzxzxz"
    key    = "s3bucket/terraform.tfstate"
    region = "us-east-1"
    
  }
}
