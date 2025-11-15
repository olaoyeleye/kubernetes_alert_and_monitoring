# VPC module (official)
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.0" # compatible stable line; change if you want specific version

  name = "monitoring-vpc"
  cidr = "10.10.0.0/16"

  azs             = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  public_subnets  = [for i in range(var.az_count) : cidrsubnet("10.10.0.0/16", 8, i + 128)]
  private_subnets = [for i in range(var.az_count) : cidrsubnet("10.10.0.0/16", 8, i + 1)]

  enable_nat_gateway = true
  single_nat_gateway = false

  tags = {
    Environment = "monitoring"
    ManagedBy   = "terraform"
  }
}

data "aws_availability_zones" "available" {}

# Security group for monitoring access
resource "aws_security_group" "monitor_sg" {
  name        = "monitoring-sg"
  description = "Allow SSH, Prometheus, Grafana, Alertmanager, Node Exporter"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    description = "Prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    description = "Alertmanager"
    from_port   = 9093
    to_port     = 9093
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    description = "Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    description = "Node exporter"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "monitoring-sg"
  }
}

# EKS module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.8.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = concat(module.vpc.private_subnets, module.vpc.public_subnets)

  # Managed node groups configuration
  eks_managed_node_groups = {
    managed_nodes = {
      instance_types = ["t3.micro"]
      min_size       = 2
      max_size       = 4
      desired_size   = 3
    }
  }

  # Enable AWS Auth ConfigMap management via Terraform
  manage_aws_auth = true

  # Example Fargate profile (optional)
  fargate_profiles = {
    default = {
      selectors = [
        { namespace = "default" },
        { namespace = "kube-system" }
      ]
    }
  }

  tags = {
    Environment = "monitoring"
    ManagedBy   = "terraform"
  }
}


# Helm child module (no provider blocks inside helm module)
module "helm" {
  source = "./helm"

  cluster_name = module.eks_cluster.cluster_id
  region       = var.region

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }

  # ensure module-level sequencing at root -- legacy modules that declare providers inside cannot accept depends_on,
  # but because the child here will not declare providers we can safely declare depends_on in the root module if needed:
  depends_on = [module.eks_cluster]
}
