variable "name" {
  description = "VPC name"
  type        = string
}

variable "cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "azs" {
  description = "Optional list of AZs. If null, module will pick automatically"
  type        = list(string)
  default     = null
}

variable "public_subnets" {
  description = "List of public subnets CIDRs"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnets CIDRs"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}


