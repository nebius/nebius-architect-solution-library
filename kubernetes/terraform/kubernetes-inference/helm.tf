data "nebius_client_config" "client" {}

resource "helm_release" "gpu-operator" {
  name             = "gpu-operator"
  repository       = "oci://cr.nemax.nebius.cloud/yc-marketplace/nebius/gpu-operator/chart/"
  chart            = "gpu-operator"
  namespace        = "gpu-operator"
  create_namespace = true
  version          = "v23.9.0"
}

provider "helm" {
  kubernetes {
    host                   = module.kube.external_v4_endpoint
    cluster_ca_certificate = module.kube.cluster_ca_certificate
    token                  = data.nebius_client_config.client.iam_token
  }
}
