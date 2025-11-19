output "jenkins_url" {
  description = "Jenkins URL"
  value       = "http://${data.kubernetes_service.jenkins.status[0].load_balancer[0].ingress[0].hostname}:8080"
}

output "jenkins_namespace" {
  description = "Jenkins namespace"
  value       = var.namespace
}

output "admin_password" {
  description = "Jenkins admin password"
  value       = data.kubernetes_secret.jenkins_admin_password.data["password"]
  sensitive   = true
}

data "kubernetes_service" "jenkins" {
  metadata {
    name      = "jenkins"
    namespace = var.namespace
  }
  depends_on = [helm_release.jenkins]
}

data "kubernetes_secret" "jenkins_admin_password" {
  metadata {
    name      = "jenkins"
    namespace = var.namespace
  }
  depends_on = [helm_release.jenkins]
}

