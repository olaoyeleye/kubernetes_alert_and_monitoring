#variable "cluster_name" { type = string }

 
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "kube_prometheus_stack" {
  name       = "monitoring-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "58.3.1"

  values = [
    file("${path.module}/values/prometheus-values.yaml")
  ]

  depends_on = [kubernetes_namespace.monitoring]
}

# nginx ingress controller to expose grafana
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.7.1"

  values = [
    file("${path.module}/values/grafana-ingress-values.yaml")
  ]
}

# test workloads
resource "kubernetes_manifest" "nginx_deployment" {
  manifest = yamldecode(file("${path.module}/templates/nginx-deployment.yaml"))
  depends_on = [helm_release.kube_prometheus_stack]
}

resource "kubernetes_manifest" "nginx_service" {
  manifest = yamldecode(file("${path.module}/templates/nginx-service.yaml"))
  depends_on = [helm_release.kube_prometheus_stack]
}


resource "kubernetes_manifest" "redis_deployment" {
  manifest = yamldecode(file("${path.module}/templates/redis-deployment.yaml"))
  depends_on = [helm_release.kube_prometheus_stack]
}

resource "kubernetes_manifest" "redis_service" {
  manifest = yamldecode(file("${path.module}/templates/redis-service.yaml"))
  depends_on = [helm_release.kube_prometheus_stack]
}



resource "kubernetes_manifest" "busybox" {
  manifest = yamldecode(file("${path.module}/templates/busybox.yaml"))
  depends_on = [helm_release.kube_prometheus_stack]
}

