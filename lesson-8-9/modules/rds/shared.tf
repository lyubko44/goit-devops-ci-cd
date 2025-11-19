# Locals for parameter group family auto-detection
locals {
  # Normalize engine name (remove aurora- prefix for parameter group detection)
  normalized_engine = replace(var.engine, "aurora-", "")
  
  # Auto-detect parameter group family if not provided
  parameter_group_family = var.parameter_group_family != "" ? var.parameter_group_family : (
    var.use_aurora ? (
      local.normalized_engine == "postgres" ? "aurora-postgresql${replace(split(".", var.engine_version)[0], ".", "")}" :
      local.normalized_engine == "mysql" ? "aurora-mysql${replace(split(".", var.engine_version)[0], ".", "")}" :
      "aurora-postgresql15" # default fallback
    ) : (
      local.normalized_engine == "postgres" ? "postgres${replace(split(".", var.engine_version)[0], ".", "")}" :
      local.normalized_engine == "mysql" ? "mysql${replace(split(".", var.engine_version)[0], ".", "")}.${split(".", var.engine_version)[1]}" :
      "postgres15" # default fallback
    )
  )
  
  # Default port based on engine (use provided port or engine default)
  db_port = var.db_port != 0 ? var.db_port : (
    local.normalized_engine == "postgres" ? 5432 :
    local.normalized_engine == "mysql" ? 3306 :
    5432 # default fallback
  )
  
  is_postgres = local.normalized_engine == "postgres"
  
  # Aurora engine type conversion
  aurora_engine = var.use_aurora ? (
    local.normalized_engine == "postgres" ? "aurora-postgresql" :
    local.normalized_engine == "mysql" ? "aurora-mysql" :
    "aurora-postgresql" # default fallback
  ) : var.engine
}

# DB Subnet Group
resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-db-subnet-group"
    }
  )
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name        = "${var.name_prefix}-rds-sg"
  description = "Security group for RDS database"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow database access from VPC"
    from_port       = local.db_port
    to_port         = local.db_port
    protocol        = "tcp"
    cidr_blocks     = [var.vpc_cidr]
    security_groups = var.allowed_security_group_ids
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-rds-sg"
    }
  )
}

# Parameter Group
resource "aws_db_parameter_group" "this" {
  count = var.use_aurora ? 0 : 1

  name   = "${var.name_prefix}-db-params"
  family = local.parameter_group_family

  parameter {
    name  = "max_connections"
    value = var.max_connections
  }

  # PostgreSQL-specific parameters
  dynamic "parameter" {
    for_each = local.is_postgres ? [1] : []
    content {
      name  = "log_statement"
      value = var.log_statement
    }
  }

  dynamic "parameter" {
    for_each = local.is_postgres ? [1] : []
    content {
      name  = "work_mem"
      value = var.work_mem
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-db-params"
    }
  )
}

# Parameter Group for Aurora Cluster
resource "aws_rds_cluster_parameter_group" "this" {
  count = var.use_aurora ? 1 : 0

  name   = "${var.name_prefix}-aurora-cluster-params"
  family = local.parameter_group_family

  parameter {
    name  = "max_connections"
    value = var.max_connections
  }

  # PostgreSQL-specific parameters
  dynamic "parameter" {
    for_each = local.is_postgres ? [1] : []
    content {
      name  = "log_statement"
      value = var.log_statement
    }
  }

  dynamic "parameter" {
    for_each = local.is_postgres ? [1] : []
    content {
      name  = "work_mem"
      value = var.work_mem
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-aurora-cluster-params"
    }
  )
}

