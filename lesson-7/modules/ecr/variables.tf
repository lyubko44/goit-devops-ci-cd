variable "repo_name" {
  description = "ECR repository name"
  type        = string
}

variable "image_scan_on_push" {
  description = "Enable image scan on push"
  type        = bool
  default     = true
}

variable "force_delete" {
  description = "Allow force delete of repository (non-production)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}


