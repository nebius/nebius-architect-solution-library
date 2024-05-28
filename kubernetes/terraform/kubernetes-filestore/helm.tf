data "nebius_client_config" "client" {}

resource "helm_release" "gpu-operator" {
  name             = "gpu-operator"
  repository       = "oci://cr.nemax.nebius.cloud/yc-marketplace/nebius/gpu-operator/chart/"
  chart            = "gpu-operator"
  namespace        = "gpu-operator"
  create_namespace = true
  version          = "v23.9.0"

  set {
    name  = "toolkit.enabled"
    value = "true"
  }

  set {
    name  = "driver.version"
    value = "535.104.12"
  }
}


resource "helm_release" "mount-filesystem" {
  depends_on = [null_resource.attach-filestore]
  name       = "mount-filesystem"
  chart      = "./mount-filesystem"
  namespace  = "default"
  #create_namespace = true
  set {
    name  = "filesystemId"
    value = nebius_compute_filesystem.k8s-shared-storage.id
  }
}


provider "helm" {
  kubernetes {
    host                   = module.kube-cluster.kube_external_v4_endpoint
    cluster_ca_certificate = module.kube-cluster.kube_cluster_ca_certificate
    token                  = data.nebius_client_config.client.iam_token
  }
}
