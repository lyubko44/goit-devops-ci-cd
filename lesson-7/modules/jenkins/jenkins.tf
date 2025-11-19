resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = var.namespace
    labels = {
      name = var.namespace
    }
  }
}

resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = var.helm_chart_version
  namespace  = kubernetes_namespace.jenkins.metadata[0].name

  values = [
    var.values_file != "" ? file(var.values_file) : file("${path.module}/values.yaml")
  ]

  depends_on = [kubernetes_namespace.jenkins]
}

