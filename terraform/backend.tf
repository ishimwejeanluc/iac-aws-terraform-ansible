
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-iac-aws"
    key            = "terraform.tfstate"
    region         = "us-west-1" 
    dynamodb_table = "my-terraform-state-lock-db-iac-aws"
    encrypt        = true
  }
}
