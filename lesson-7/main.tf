terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

#########################
# Root-level variables  #
#########################

variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "eu-central-1"
}

variable "project" {
  description = "Project prefix used when naming resources"
  type        = string
  default     = "goit-devops"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "lesson-7"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnets" {
  description = "Public subnets CIDRs"
  type        = list(string)
  default     = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]
}

variable "private_subnets" {
  description = "Private subnets CIDRs"
  type        = list(string)
  default     = ["10.20.11.0/24", "10.20.12.0/24", "10.20.13.0/24"]
}

variable "create_vpc" {
  description = "Create a new VPC (true) or reuse existing from lesson 4/5 (false)"
  type        = bool
  default     = false
}

variable "existing_vpc_id" {
  description = "Existing VPC ID to reuse (from lesson 4/5). Required if create_vpc=false"
  type        = string
  default     = ""
}

variable "existing_private_subnet_ids" {
  description = "Existing private subnet IDs to reuse (from lesson 4/5). Required if create_vpc=false"
  type        = list(string)
  default     = []
}

locals {
  name_prefix = "${var.project}-${var.environment}"
  tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

locals {
  selected_vpc_id             = var.create_vpc ? module.vpc[0].vpc_id : var.existing_vpc_id
  selected_private_subnet_ids = var.create_vpc ? module.vpc[0].private_subnet_ids : var.existing_private_subnet_ids
  selected_public_subnet_ids  = var.create_vpc ? module.vpc[0].public_subnet_ids : []
}

#########################
# Modules               #
#########################

module "vpc" {
  count = var.create_vpc ? 1 : 0
  source = "./modules/vpc"

  name                 = "${local.name_prefix}-vpc"
  cidr                 = var.vpc_cidr
  public_subnets       = var.public_subnets
  private_subnets      = var.private_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = true
  tags                 = local.tags
}

module "ecr" {
  source = "./modules/ecr"

  repo_name            = "${local.name_prefix}-django"
  image_scan_on_push   = true
  force_delete         = false
  tags                 = local.tags
}

module "eks" {
  source = "./modules/eks"

  cluster_name         = "${local.name_prefix}-eks"
  kubernetes_version   = "1.29"

  vpc_id               = local.selected_vpc_id
  private_subnet_ids   = local.selected_private_subnet_ids

  desired_size         = 2
  min_size             = 2
  max_size             = 6
  instance_types       = ["t3.medium"]
  tags                 = local.tags
}

module "jenkins" {
  source = "./modules/jenkins"

  cluster_name         = module.eks.cluster_name
  cluster_endpoint     = module.eks.cluster_endpoint
  cluster_ca_certificate = module.eks.cluster_ca_certificate
  aws_region           = var.aws_region
  namespace            = "jenkins"
  helm_chart_version   = "5.0.0"
  tags                 = local.tags

  depends_on = [module.eks]
}

module "argo_cd" {
  source = "./modules/argo_cd"

  cluster_name         = module.eks.cluster_name
  cluster_endpoint     = module.eks.cluster_endpoint
  cluster_ca_certificate = module.eks.cluster_ca_certificate
  aws_region           = var.aws_region
  namespace            = "argocd"
  helm_chart_version   = "7.0.0"
  tags                 = local.tags

  depends_on = [module.eks]
}


