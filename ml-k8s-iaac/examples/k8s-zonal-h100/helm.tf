data "nebius_client_config" "client" {}

resource "helm_release" "descheduler" {
  name       = "helm-descheduler"
  chart      = "../../helm-descheduler"
  namespace = "descheduler"
  create_namespace = true
  values = [
    "${file("../../helm-descheduler/values-my.yaml")}"
  ]
}

resource "helm_release" "gpu-operator" {
  name       = "gpu-operator"
  chart      = "../../gpu-operator"
  namespace = "gpu-operator"
  create_namespace = true
  values = [
    "${file("../../gpu-operator/values.yaml")}"
  ]
}

resource "helm_release" "kube-prometheus-stack" {
  name       = "kube-prometheus-stack"
  chart      = "../../kube-prometheus-stack"
  namespace = "prometheus"
  create_namespace = true
  values = [
    "${file("../../kube-prometheus-stack/values.yaml")}"
  ]
}

resource "helm_release" "network_operator" {
  name       = "network-operator"
  chart      = "../../network-operator"
  namespace = "network-operator"
  create_namespace = true
  values = [
    "${file("../../network-operator/values.yaml")}"
  ]
}

provider "helm" {
    kubernetes {
      host                   = module.kube.external_v4_endpoint
      cluster_ca_certificate = module.kube.cluster_ca_certificate
      token                  = data.nebius_client_config.client.iam_token
    }
}