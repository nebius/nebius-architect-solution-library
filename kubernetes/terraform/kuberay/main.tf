data "nebius_client_config" "client" {}

resource "helm_release" "kuberay-operator" {
  name             = var.kuberay_name
  repository       = var.kuberay_repository_path
  chart            = var.kuberay_chart_name
  namespace        = var.kuberay_namespace
  create_namespace = var.kuberay_create_namespace
  version          = "1.1.0"
  values           = [
    "${file("../kuberay/helm/ray-values.yaml")}"
  ]
  set {
    name  = "worker.maxReplicas"
    value = var.gpu_workers
  }
  set {
    name  = "worker.minReplicas"
    value = 1
  }

}
