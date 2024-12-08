provider "aws" {
  region = "us-east-1"
  
}

terraform {
  backend "s3" {
    bucket = "loadbucket123"
    key = "first/next/terraform.tfstate"
    region = "us-east-1"
  }
}
