terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.97.0"
    }
  }
}


provider "aws" {
  region = "eu-west-3"
}


resource "aws_s3_bucket" "terraform_state" {
  bucket = "practice-eks-bucket"

  lifecycle {
    prevent_destroy = false
  }
}


terraform {  
  backend "s3" {  
    bucket       = "practice-eks-bucket"  
    key          = "dev/terraform-state-file"
    region       = "eu-west-3"  
    encrypt      = true  
    use_lockfile = true  #S3 native locking
  }  
}



module "vpc" {
  source = "./modules/vpc"

  region              = var.region
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones  # List of availability zones to distribute subnets across
  private_subnet_cidr = var.private_subnet_cidr # CIDR blocks for private subnets
  public_subnet_cidr  = var.public_subnet_cidr  # CIDR blocks for public subnets
  eks_cluster_name    = var.eks_cluster_name    # Optional: used inside VPC module for tagging or naming
}


module "eks" {
  source = "./modules/eks"

  region           = var.region
  eks_cluster_name = var.eks_cluster_name         # Name of the EKS cluster to create
  cluster_version  = var.cluster_version          # Kubernetes version for the EKS control plane
  vpc_id           = module.vpc.vpc_id            # Use VPC ID output from the VPC module
  subnet_id        = module.vpc.private_subnet_ids # Use private subnet IDs from the VPC module
  node_groups      = var.node_groups              # Map of node group configurations to launch worker nodes
}