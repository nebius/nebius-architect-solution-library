data "nebius_client_config" "client" {}




resource "helm_release" "gpu_operator" {
  name             = "gpu-operator"
  repository       = "oci://cr.nemax.nebius.cloud/yc-marketplace/nebius/nvidia-gpu-operator/chart/"
  chart            = "gpu-operator"
  namespace        = "gpu-operator"
  create_namespace = true
  version          = "v23.9.0"

  set {
    name  = "toolkit.enabled"
    value = "true"
  }

  set {
    name  = "driver.rdma.enabled"
    value = "true"
  }
}

resource "helm_release" "network_operator" {
  name       = "network-operator"
  repository = "oci://cr.nemax.nebius.cloud/yc-marketplace/nebius/elijahk-nvidia-network-operator/chart"
  chart      = "network-operator"
  namespace  = "network-operator"

  create_namespace = true
  version          = "24.4.0"
}

resource "helm_release" "kuberay-operator" {
  name       = "ray-cluster"
  repository = "oci://cr.nemax.nebius.cloud/yc-marketplace/nebius/ray-cluster/chart/"
  chart      = "ray-cluster"
  namespace  = "ray-cluster"
  create_namespace = true
  version          = "1.1.0"
  values = [
    "${file("helm/ray-values.yaml")}"
  ]
}

provider "helm" {
  kubernetes {
    host                   = module.kube.external_v4_endpoint
    cluster_ca_certificate = module.kube.cluster_ca_certificate
    token                  = data.nebius_client_config.client.iam_token
  }
}