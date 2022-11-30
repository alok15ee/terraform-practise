# Terraform Block
terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Provider Block
provider "aws" {
  region  = "us-west-2"
  profile = "default"
}


resource "aws_instance" "ec2demo" {
  ami = "ami-0d593311db5abb72b"
  instance_type = "t2.micro"
  # root disk
  root_block_device {
    volume_size           = "20"
    volume_type           = "gp2"
    encrypted             = true
    delete_on_termination = true
  }
  # data disk
  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = "50"
    volume_type           = "gp2"
    encrypted             = true
    delete_on_termination = true
  }
  tags = {
    Name = "ec2-terraform"
  }
}