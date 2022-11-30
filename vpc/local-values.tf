# Define Local Values in Terraform
locals {
  owners = "asingh"
  environment = "dev"
  name = "${local.owners}-${local.environment}"
  common_tags = {
    owners = local.owners
    environment = local.environment
  }
  eks_cluster_name = "${local.name}-${var.cluster_name}"  
}  