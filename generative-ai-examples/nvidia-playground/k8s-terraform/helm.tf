data "nebius_client_config" "client" {}

resource "helm_release" "gpu-operator" {
  name       = "gpu-operator"
  repository = "oci://cr.nemax.nebius.cloud/yc-marketplace/nebius/gpu-operator/chart/"
  chart      = "gpu-operator"
  namespace = "gpu-operator"
  create_namespace = true
  version = "v23.9.0"

  set {
    name  = "toolkit.enabled"
    value = "true"
  }

  set {
    name  = "driver.version"
    value = "535.104.12"
  }
}

resource "helm_release" "kube-prometheus-stack" {
  name       = "kube-prometheus-stack"
  chart      = "../../../ml-k8s-iaac/kube-prometheus-stack"
  namespace = "prometheus"
  create_namespace = true
  values = [
    "${file("../../../ml-k8s-iaac/kube-prometheus-stack/values.yaml")}"
  ]
}

resource "helm_release" "nvidia-playground" {
  name       = "nvidia-playground"
  chart      = "../helm"
  namespace = "default"
  create_namespace = false
  values = [
    "${file("../helm/values.yaml")}"
  ]
}


provider "helm" {
    kubernetes {
      host                   = module.kube.external_v4_endpoint
      cluster_ca_certificate = module.kube.cluster_ca_certificate
      token                  = data.nebius_client_config.client.iam_token
    }
}