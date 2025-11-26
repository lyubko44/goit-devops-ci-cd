output "vpc_id" {
  value       = local.selected_vpc_id
  description = "VPC ID"
}

output "private_subnet_ids" {
  value       = local.selected_private_subnet_ids
  description = "Private subnet IDs"
}

output "public_subnet_ids" {
  value       = local.selected_public_subnet_ids
  description = "Public subnet IDs (empty if reusing existing VPC)"
}

output "ecr_repository_url" {
  value       = module.ecr.repository_url
  description = "ECR repository URL for the Django image"
}

output "eks_cluster_name" {
  value       = module.eks.cluster_name
  description = "EKS cluster name"
}

output "eks_cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "EKS cluster endpoint"
}

output "eks_cluster_ca_certificate" {
  value       = module.eks.cluster_ca_certificate
  description = "EKS cluster CA certificate (base64)"
}

output "eks_oidc_provider_arn" {
  value       = module.eks.oidc_provider_arn
  description = "EKS OIDC provider ARN"
}

output "jenkins_url" {
  value       = module.jenkins.jenkins_url
  description = "Jenkins URL"
}

output "jenkins_admin_password" {
  value       = module.jenkins.admin_password
  description = "Jenkins admin password"
  sensitive   = true
}

output "argocd_url" {
  value       = module.argo_cd.argocd_url
  description = "Argo CD URL"
}

output "argocd_admin_password" {
  value       = module.argo_cd.admin_password
  description = "Argo CD initial admin password"
  sensitive   = true
}

output "rds_database_endpoint" {
  value       = module.rds.database_endpoint
  description = "RDS database endpoint (works for both RDS and Aurora)"
}

output "rds_database_port" {
  value       = module.rds.database_port
  description = "RDS database port"
}

output "rds_database_name" {
  value       = module.rds.database_name
  description = "RDS database name"
}

output "rds_instance_id" {
  value       = module.rds.rds_instance_id
  description = "RDS Instance ID (null if Aurora)"
}

output "aurora_cluster_id" {
  value       = module.rds.aurora_cluster_id
  description = "Aurora Cluster ID (null if regular RDS)"
}

output "aurora_cluster_endpoint" {
  value       = module.rds.aurora_cluster_endpoint
  description = "Aurora Cluster Writer Endpoint (null if regular RDS)"
}

output "aurora_cluster_reader_endpoint" {
  value       = module.rds.aurora_cluster_reader_endpoint
  description = "Aurora Cluster Reader Endpoint (null if regular RDS)"
}

output "prometheus_url" {
  value       = module.monitoring.prometheus_url
  description = "Prometheus service URL"
}

output "grafana_url" {
  value       = module.monitoring.grafana_url
  description = "Grafana service URL"
}

output "grafana_admin_password" {
  value       = module.monitoring.grafana_admin_password
  description = "Grafana admin password"
  sensitive   = true
}

output "monitoring_namespace" {
  value       = module.monitoring.namespace
  description = "Monitoring namespace"
}


