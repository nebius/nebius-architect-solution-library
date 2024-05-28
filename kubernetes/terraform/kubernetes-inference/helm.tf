data "nebius_client_config" "client" {}

# resource "helm_release" "descheduler" {
#   name       = "helm-descheduler"
#   repository = "https://kubernetes-sigs.github.io/descheduler/"
#   chart      = "descheduler"
#   namespace = "descheduler"
#   create_namespace = true
#   # values = [
#   #   "${file("../../helm-descheduler/values-my.yaml")}"
#   # ]
# }

resource "helm_release" "gpu-operator" {
  count = var.gpu_env == "runc" ? 1:0
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

# resource "helm_release" "kube-prometheus-stack" {
#   name       = "kube-prometheus-stack"
#   chart      = "../../kube-prometheus-stack"
#   namespace = "prometheus"
#   create_namespace = true
#   values = [
#     "${file("../../kube-prometheus-stack/values.yaml")}"
#   ]
# }



provider "helm" {
    kubernetes {
      host                   = module.kube.external_v4_endpoint
      cluster_ca_certificate = module.kube.cluster_ca_certificate
      token                  = data.nebius_client_config.client.iam_token
    }
}
