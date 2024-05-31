data "nebius_client_config" "client" {}
provider "helm" {
  kubernetes {
    host                   = module.kube.external_v4_endpoint
    cluster_ca_certificate = module.kube.cluster_ca_certificate
    token                  = data.nebius_client_config.client.iam_token
  }
}

resource "helm_release" "mount-filesystem" {
  depends_on       = [module.kube]
  repository       = "./helm/"
  name             = "mount-filesystem"
  chart            = "mount-filesystem"
  namespace        = "glusterfs"
  create_namespace = true
  version          = "0.1.0"

  set {
    name  = "shared_volume_host_path"
    value = var.glusterfs_mount_host_path
  }

  set {
    name  = "glusterfs_hostname"
    value = module.gluster-fs-cluster.glusterfs-host
  }
}
