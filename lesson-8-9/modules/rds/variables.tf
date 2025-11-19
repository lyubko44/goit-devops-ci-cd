variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where RDS will be deployed"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block for security group rules"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for DB subnet group"
  type        = list(string)
}

variable "use_aurora" {
  description = "Create Aurora Cluster (true) or regular RDS instance (false)"
  type        = bool
  default     = false
}

# Database Configuration
variable "engine" {
  description = "Database engine (postgres, mysql, etc.). For Aurora, use 'postgres' or 'mysql' - module will convert to 'aurora-postgresql' or 'aurora-mysql' automatically"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
  default     = "15.4"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "mydb"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "db_port" {
  description = "Database port (0 = auto-detect based on engine)"
  type        = number
  default     = 0
}

# Storage Configuration (for RDS instance)
variable "allocated_storage" {
  description = "Allocated storage in GB (for RDS instance)"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum allocated storage in GB (for RDS instance autoscaling)"
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "Storage type (gp2, gp3, io1, etc.)"
  type        = string
  default     = "gp3"
}

variable "storage_encrypted" {
  description = "Enable storage encryption"
  type        = bool
  default     = true
}

# High Availability
variable "multi_az" {
  description = "Enable Multi-AZ deployment (for RDS instance)"
  type        = bool
  default     = false
}

variable "aurora_replica_count" {
  description = "Number of Aurora read replicas (in addition to writer)"
  type        = number
  default     = 0
}

# Network Configuration
variable "publicly_accessible" {
  description = "Make database publicly accessible"
  type        = bool
  default     = false
}

variable "allowed_security_group_ids" {
  description = "List of security group IDs allowed to access the database"
  type        = list(string)
  default     = []
}

# Parameter Group Configuration
variable "parameter_group_family" {
  description = "Parameter group family (e.g., postgres15, mysql8.0). If not specified, will be auto-detected from engine and engine_version"
  type        = string
  default     = ""
}

variable "max_connections" {
  description = "Maximum number of database connections"
  type        = string
  default     = "100"
}

variable "log_statement" {
  description = "Log statement level (none, ddl, mod, all)"
  type        = string
  default     = "all"
}

variable "work_mem" {
  description = "Work memory in MB"
  type        = string
  default     = "4"
}

# Backup Configuration
variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Preferred backup window (UTC)"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Preferred maintenance window (UTC)"
  type        = string
  default     = "mon:04:00-mon:05:00"
}

# Monitoring
variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to export to CloudWatch"
  type        = list(string)
  default     = ["postgresql", "upgrade"]
}

# Snapshot Configuration
variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion"
  type        = bool
  default     = false
}

# Tags
variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

