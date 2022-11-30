
resource "aws_eks_cluster" "eks_cluster" {

  name = var.cluster_name
  role_arn = aws_iam_role.eks_master_role.arn


## this will create eks elastic network interface in the public subnet
  vpc_config {
    subnet_ids = module.vpc.public_subnets
    endpoint_public_access = var.cluster_endpoint_public_access
    endpoint_private_access = var.cluster_endpoint_private_access
    public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  }

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster#kubernetes_network_config
# important to restrict the pods/node within a specific cidr
# modification on the cidr creates new cluster

  kubernetes_network_config {
    service_ipv4_cidr = var.cluster_service_ipv4_cidr
  }

  enabled_cluster_log_types = ["api", "audit","authenticator", "controllerManager", "scheduler"]

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKSVPCResourceController,
  ]
}

variable "instance_keypair" {
  description = "AWS EC2 Key pair that need to be associated with EC2 Instance"
  type = string
  default = "eks-terraform-key"
}


# Create AWS EKS Node Group - Public
resource "aws_eks_node_group" "eks_node_group_public" {
  cluster_name    = aws_eks_cluster.eks_cluster.name

  node_group_name = "${var.cluster_name}-eks-ng-public"
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
  subnet_ids      = module.vpc.public_subnets
  #version = var.cluster_version #(Optional: Defaults to EKS Cluster Kubernetes version)    
  
  ami_type = "AL2_x86_64"  
  capacity_type = "ON_DEMAND"
  disk_size = 20
  instance_types = ["t3.medium"]
  
  
  remote_access {
    ec2_ssh_key = "dev-ops-key-pair"
  }

  scaling_config {
    desired_size = 1
    min_size     = 1    
    max_size     = 2
  }

  # Desired max percentage of unavailable worker nodes during node group update.
  update_config {
    max_unavailable = 1    
    #max_unavailable_percentage = 50    # ANY ONE TO USE
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly,
  ] 

  tags = {
    Name = "Public-Node-Group"
  }
}




module "vpc" {
  source = "../vpc"
}
