variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_endpoint" {
  description = "EKS cluster endpoint"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "EKS cluster CA certificate (base64)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "namespace" {
  description = "Kubernetes namespace for monitoring"
  type        = string
  default     = "monitoring"
}

variable "helm_chart_version" {
  description = "kube-prometheus-stack Helm chart version"
  type        = string
  default     = "55.0.0"
}

variable "repo_url" {
  description = "Helm repository URL for kube-prometheus-stack"
  type        = string
  default     = "https://prometheus-community.github.io/helm-charts"
}

variable "values_file" {
  description = "Path to values.yaml file for monitoring"
  type        = string
  default     = ""
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

