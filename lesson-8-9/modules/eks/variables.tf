variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.29"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for worker nodes"
  type        = list(string)
}

variable "desired_size" {
  description = "Desired node count"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Min node count"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Max node count"
  type        = number
  default     = 6
}

variable "instance_types" {
  description = "Instance types for node groups"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}


