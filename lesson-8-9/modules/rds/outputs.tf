# DB Subnet Group Outputs
output "db_subnet_group_id" {
  description = "DB Subnet Group ID"
  value       = aws_db_subnet_group.this.id
}

output "db_subnet_group_name" {
  description = "DB Subnet Group Name"
  value       = aws_db_subnet_group.this.name
}

# Security Group Outputs
output "security_group_id" {
  description = "Security Group ID for RDS"
  value       = aws_security_group.rds.id
}

# Parameter Group Outputs
output "parameter_group_id" {
  description = "Parameter Group ID (for RDS instance)"
  value       = var.use_aurora ? null : aws_db_parameter_group.this[0].id
}

output "parameter_group_name" {
  description = "Parameter Group Name (for RDS instance)"
  value       = var.use_aurora ? null : aws_db_parameter_group.this[0].name
}

output "cluster_parameter_group_id" {
  description = "Cluster Parameter Group ID (for Aurora)"
  value       = var.use_aurora ? aws_rds_cluster_parameter_group.this[0].id : null
}

output "cluster_parameter_group_name" {
  description = "Cluster Parameter Group Name (for Aurora)"
  value       = var.use_aurora ? aws_rds_cluster_parameter_group.this[0].name : null
}

# RDS Instance Outputs (when use_aurora = false)
output "rds_instance_id" {
  description = "RDS Instance ID"
  value       = var.use_aurora ? null : aws_db_instance.this[0].id
}

output "rds_instance_arn" {
  description = "RDS Instance ARN"
  value       = var.use_aurora ? null : aws_db_instance.this[0].arn
}

output "rds_instance_endpoint" {
  description = "RDS Instance Endpoint"
  value       = var.use_aurora ? null : aws_db_instance.this[0].endpoint
}

output "rds_instance_address" {
  description = "RDS Instance Address"
  value       = var.use_aurora ? null : aws_db_instance.this[0].address
}

output "rds_instance_port" {
  description = "RDS Instance Port"
  value       = var.use_aurora ? null : aws_db_instance.this[0].port
}

# Aurora Cluster Outputs (when use_aurora = true)
output "aurora_cluster_id" {
  description = "Aurora Cluster ID"
  value       = var.use_aurora ? aws_rds_cluster.this[0].id : null
}

output "aurora_cluster_arn" {
  description = "Aurora Cluster ARN"
  value       = var.use_aurora ? aws_rds_cluster.this[0].arn : null
}

output "aurora_cluster_endpoint" {
  description = "Aurora Cluster Writer Endpoint"
  value       = var.use_aurora ? aws_rds_cluster.this[0].endpoint : null
}

output "aurora_cluster_reader_endpoint" {
  description = "Aurora Cluster Reader Endpoint"
  value       = var.use_aurora ? aws_rds_cluster.this[0].reader_endpoint : null
}

output "aurora_cluster_port" {
  description = "Aurora Cluster Port"
  value       = var.use_aurora ? aws_rds_cluster.this[0].port : null
}

output "aurora_cluster_instance_ids" {
  description = "Aurora Cluster Instance IDs"
  value       = var.use_aurora ? concat(aws_rds_cluster_instance.writer[*].id, aws_rds_cluster_instance.readers[*].id) : []
}

# Common Outputs
output "database_name" {
  description = "Database name"
  value       = var.db_name
}

output "database_username" {
  description = "Database master username"
  value       = var.db_username
  sensitive   = true
}

# Unified endpoint output (works for both RDS and Aurora)
output "database_endpoint" {
  description = "Database endpoint (works for both RDS and Aurora)"
  value       = var.use_aurora ? aws_rds_cluster.this[0].endpoint : aws_db_instance.this[0].endpoint
}

output "database_port" {
  description = "Database port"
  value       = local.db_port
}

