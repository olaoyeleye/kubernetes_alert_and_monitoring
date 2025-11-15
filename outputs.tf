output "cluster_endpoint" {
  value = module.eks_cluster.cluster_endpoint
}

output "kubeconfig_certificate" {
  value = module.ekeks_clusters.cluster_certificate_authority_data
}

output "cluster_name" {
  value = module.eks_cluster.cluster_id
}
