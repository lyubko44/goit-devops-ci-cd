variable "bucket_name" {
  description = "Name of the S3 bucket to store Terraform state"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
}

variable "force_destroy" {
  description = "Allow destroying non-empty bucket (for test envs)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}


