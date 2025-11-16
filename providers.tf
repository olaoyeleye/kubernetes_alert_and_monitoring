# provider "aws" {
#  region = var.region
# }

data "aws_eks_cluster" "cluster" {
  name       = module.eks.cluster_id # FIX: Use .cluster_id
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "cluster" {
  name       = module.eks.cluster_id # FIX: Use .cluster_id
  depends_on = [module.eks]
}

# Default kubernetes provider (used by modules that reference `kubernetes`)
#provider "kubernetes" {
#  host                   = data.aws_eks_cluster.cluster.endpoint
#  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
#  token                  = data.aws_eks_cluster_auth.cluster.token

  # Do not load KUBECONFIG automatically from file in this setup:
  #load_config_file = false
#}

# Helm provider — configured to use the same EKS data (this creates the provider named "helm")
#provider "helm" {
#  kubernetes {
#    host                   = data.aws_eks_cluster.cluster.endpoint
#    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
#    token                  = data.aws_eks_cluster_auth.cluster.token
#  }
#}


resource "kubernetes_config_map" "aws_auth" {
  depends_on = [module.eks]
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      {
        # Using managed_node_groups to get the ARN from the managed node group output
        rolearn  = module.eks.eks_managed_node_groups["managed_nodes"].iam_role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = [
          "system:bootstrappers",
          "system:nodes"
        ]
      }
    ])
  }
}