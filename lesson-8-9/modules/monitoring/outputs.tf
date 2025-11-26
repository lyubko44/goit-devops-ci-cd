output "prometheus_url" {
  value       = "http://kube-prometheus-stack-prometheus.${var.namespace}.svc.cluster.local:9090"
  description = "Prometheus service URL"
}

output "grafana_url" {
  value       = try("http://${data.kubernetes_service.grafana.status[0].load_balancer[0].ingress[0].hostname}:80", "http://kube-prometheus-stack-grafana.${var.namespace}.svc.cluster.local:80")
  description = "Grafana LoadBalancer URL"
}

output "grafana_admin_password" {
  value       = var.grafana_admin_password
  description = "Grafana admin password"
  sensitive   = true
}

output "namespace" {
  value       = var.namespace
  description = "Monitoring namespace"
}

data "kubernetes_service" "grafana" {
  metadata {
    name      = "kube-prometheus-stack-grafana"
    namespace = var.namespace
  }
  depends_on = [helm_release.kube_prometheus_stack]
}

