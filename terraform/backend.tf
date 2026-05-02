terraform {
  backend "s3" {
    bucket = "xzxzxz"
    key    = "s3terraform.tfstate"
    region = "us-east-1"
  }
}
