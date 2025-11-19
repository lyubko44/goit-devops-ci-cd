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
  description = "Kubernetes namespace for Argo CD"
  type        = string
  default     = "argocd"
}

variable "helm_chart_version" {
  description = "Argo CD Helm chart version"
  type        = string
  default     = "7.0.0"
}

variable "repo_url" {
  description = "Helm repository URL for Argo CD"
  type        = string
  default     = "https://argoproj.github.io/argo-helm"
}

variable "values_file" {
  description = "Path to values.yaml file for Argo CD"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

