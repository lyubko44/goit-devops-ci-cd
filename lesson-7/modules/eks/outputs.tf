output "cluster_name" {
  value       = module.eks.cluster_name
  description = "Cluster name"
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "Cluster API endpoint"
}

output "cluster_ca_certificate" {
  value       = module.eks.cluster_certificate_authority_data
  description = "Cluster CA certificate (base64)"
}

output "oidc_provider_arn" {
  value       = module.eks.oidc_provider_arn
  description = "OIDC provider ARN"
}

output "node_group_role_arns" {
  value       = module.eks.eks_managed_node_groups["default"].iam_role_arn
  description = "IAM role ARN for the default managed node group"
}


