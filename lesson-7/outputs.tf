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


