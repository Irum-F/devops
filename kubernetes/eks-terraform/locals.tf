locals {
  name   = "eks-lab"
  domain = "lab.irum.dev"
  region = "ap-south-1"
  tags = {
    Environment = "sandbox"
    Project     = "EKS Advanced Lab"
    Owner       = "Irum"
  }
}