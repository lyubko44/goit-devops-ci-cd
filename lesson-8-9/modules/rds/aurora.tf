# Aurora Cluster (created when use_aurora = true)
resource "aws_rds_cluster" "this" {
  count = var.use_aurora ? 1 : 0

  cluster_identifier      = "${var.name_prefix}-aurora-cluster"
  engine                  = local.aurora_engine
  engine_version          = var.engine_version
  engine_mode             = "provisioned"
  database_name           = var.db_name
  master_username         = var.db_username
  master_password         = var.db_password
  port                    = local.db_port

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this[0].name

  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.backup_window
  preferred_maintenance_window = var.maintenance_window

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  storage_encrypted               = var.storage_encrypted

  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.name_prefix}-aurora-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-aurora-cluster"
    }
  )
}

# Aurora Cluster Instance (Writer)
resource "aws_rds_cluster_instance" "writer" {
  count = var.use_aurora ? 1 : 0

  identifier         = "${var.name_prefix}-aurora-instance-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.this[0].id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.this[0].engine
  engine_version     = aws_rds_cluster.this[0].engine_version

  publicly_accessible = var.publicly_accessible

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-aurora-instance-${count.index + 1}"
    }
  )
}

# Optional: Additional Aurora Cluster Instances (for read replicas)
resource "aws_rds_cluster_instance" "readers" {
  count = var.use_aurora && var.aurora_replica_count > 0 ? var.aurora_replica_count : 0

  identifier         = "${var.name_prefix}-aurora-instance-${count.index + 2}"
  cluster_identifier = aws_rds_cluster.this[0].id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.this[0].engine
  engine_version     = aws_rds_cluster.this[0].engine_version

  publicly_accessible = var.publicly_accessible

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-aurora-instance-${count.index + 2}"
    }
  )
}

