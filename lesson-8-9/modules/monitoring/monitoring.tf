resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.namespace
    labels = {
      name = var.namespace
    }
  }
}

resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = var.repo_url
  chart      = "kube-prometheus-stack"
  version    = var.helm_chart_version
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  values = [
    var.values_file != "" ? file(var.values_file) : file("${path.module}/values.yaml")
  ]

  depends_on = [kubernetes_namespace.monitoring]
}

