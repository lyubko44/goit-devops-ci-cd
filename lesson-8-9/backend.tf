terraform {
  backend "s3" {
    # IMPORTANT: Ensure this S3 bucket and DynamoDB table exist before init,
    # or bootstrap them once using the module in modules/s3-backend with local state.
    bucket         = "goit-devops-tf-state"
    key            = "lesson-8-9/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "goit-devops-tf-locks"
    encrypt        = true
  }
}


