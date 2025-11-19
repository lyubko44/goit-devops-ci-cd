output "argocd_url" {
  description = "Argo CD URL"
  value       = "http://${data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname}"
}

output "argocd_namespace" {
  description = "Argo CD namespace"
  value       = var.namespace
}

output "admin_password" {
  description = "Argo CD initial admin password"
  value       = data.kubernetes_secret.argocd_admin_password.data["password"]
  sensitive   = true
}

data "kubernetes_service" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = var.namespace
  }
  depends_on = [helm_release.argocd]
}

data "kubernetes_secret" "argocd_admin_password" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = var.namespace
  }
  depends_on = [helm_release.argocd]
}

