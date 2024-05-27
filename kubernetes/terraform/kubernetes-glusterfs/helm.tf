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
}
