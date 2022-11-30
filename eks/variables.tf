# EKS Cluster Input Variables
variable "cluster_name" {
  type        = string
}

variable "cluster_endpoint_public_access" {
   type = bool
}

variable "cluster_endpoint_private_access" {
  type = bool
}

variable "cluster_service_ipv4_cidr" {
  type = string
}

variable "cluster_endpoint_public_access_cidrs" {
  type = list(string)
}

