data "nebius_client_config" "client" {}

# resource "helm_release" "gpu_operator" {
#   name       = "gpu-operator"   # Name of your Helm release
#   chart      = "../../gpu-operator"
#   namespace = "gpu-operator"
#   create_namespace = true
  # values = [
  #   "${file("../../gpu-operator/values.yaml")}"
  # ]

#   set {
#     name  = "toolkit.enabled"
#     value = "true"
#   }

#   set {
#     name  = "driver.rdma.enabled"
#     value = "true"
#   }

#   set {
#     name  = "driver.version"
#     value = "535.104.12"
#   }
# }


resource "helm_release" "gpu_operator" {
  name       = "gpu-operator"
  repository = "https://helm.ngc.nvidia.com/nvidia"
  chart      = "gpu-operator"
  version    = "v23.9.0"  # Specify the version you want to use
  namespace = "gpu-operator"
  create_namespace = true

  set {
    name  = "toolkit.enabled"
    value = "true"
  }

  set {
    name  = "driver.rdma.enabled"
    value = "true"
  }

  set {
    name  = "driver.version"
    value = "535.104.12"
  }
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