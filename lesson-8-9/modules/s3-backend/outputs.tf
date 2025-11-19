output "bucket_name" {
  value       = aws_s3_bucket.state.bucket
  description = "S3 state bucket name"
}

output "bucket_arn" {
  value       = aws_s3_bucket.state.arn
  description = "S3 state bucket ARN"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.locks.name
  description = "DynamoDB locks table name"
}

output "dynamodb_table_arn" {
  value       = aws_dynamodb_table.locks.arn
  description = "DynamoDB locks table ARN"
}


