resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
    labels = {
      name = var.namespace
    }
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = var.repo_url
  chart      = "argo-cd"
  version    = var.helm_chart_version
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [
    var.values_file != "" ? file(var.values_file) : file("${path.module}/values.yaml")
  ]

  depends_on = [kubernetes_namespace.argocd]
}

