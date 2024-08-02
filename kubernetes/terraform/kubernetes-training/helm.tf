data "nebius_client_config" "client" {}




resource "helm_release" "gpu_operator" {
  name             = "gpu-operator"
  repository       = "oci://cr.nemax.nebius.cloud/yc-marketplace/nebius/elijahk-nvidia-gpu-operator/chart/"
  chart            = "gpu-operator"
  namespace        = "gpu-operator"
  create_namespace = true
  version          = "v24.3.0"

  /* Uncomment to use driver version 550.54.15 instead of default version.
  set {
    name  = "driver.version"
    value = "550.54.15"
  }
  */
}

resource "helm_release" "network_operator" {
  name       = "network-operator"
  repository = "oci://cr.nemax.nebius.cloud/yc-marketplace/nebius/network-operator/chart/"
  chart      = "network-operator"
  namespace  = "network-operator"

  create_namespace = true
  version          = "23.7.0"

}

provider "helm" {
  kubernetes {
    host                   = module.kube.external_v4_endpoint
    cluster_ca_certificate = module.kube.cluster_ca_certificate
    token                  = data.nebius_client_config.client.iam_token
  }
}