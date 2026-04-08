variable "s3_bucket_name" {
  description = "The name of the S3 bucket for Terraform state"
  type        = string
  default = "devops-lab-tf-state-123456789" 
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table for Terraform state locking"
  type        = string
  default     = "devops-lab-tf-lock"
}

variable "aws_region" {
  description = "The AWS region to create resources in"
  type        = string
  default     = "us-west-1"
}
