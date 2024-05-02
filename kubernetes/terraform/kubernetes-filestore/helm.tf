data "nebius_client_config" "client" {}

resource "helm_release" "mount-filesystem" {
  depends_on = [null_resource.attach-filestore]
  name       = "mount-filesystem"
  chart      = var.helm_path#"./mount-filesystem"
  namespace = "default"
  #create_namespace = true
  set {
    name  = "filesystemId"
    value = "${nebius_compute_filesystem.k8s-shared-storage.id}"
  }
}



provider "helm" {
    kubernetes {
      host                   = module.kube-cluster.kube_external_v4_endpoint
      cluster_ca_certificate = module.kube-cluster.kube_cluster_ca_certificate
      token                  = data.nebius_client_config.client.iam_token
    }
}