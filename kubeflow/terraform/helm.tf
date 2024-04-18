data "nebius_client_config" "client" {}


# resource "helm_release" "gpu_operator" {
#   name       = "gpu-operator"
#   repository = "oci://cr.nemax.nebius.cloud/yc-marketplace/nebius/gpu-operator/chart/"
#   chart      = "gpu-operator"
#   namespace = "gpu-operator"
#   create_namespace = true
#   version = "v23.9.0"

#   set {
#     name  = "toolkit.enabled"
#     value = "true"
#   }

# set {
#     name  = "driver.rdma.enabled"
#     value = "true"
#   }
#   set {
#     name  = "driver.version"
#     value = "535.104.12"
#   }
# }

# resource "helm_release" "network_operator" {
#   name       = "network-operator"
#   repository = "oci://cr.nemax.nebius.cloud/yc-marketplace/nebius/network-operator/chart/"
#   chart      = "network-operator"
#   namespace = "network-operator"

#   create_namespace = true
#   version = "23.7.0"

# }

resource "helm_release" "argo-cd" {
  name       = "argocd"
  repository = "oci://cr.nemax.nebius.cloud/yc-marketplace/nebius/argocd/chart/"
  chart      = "argo-cd"
  namespace = "argocd"
  create_namespace = true
  version = "5.46.8-6"
}


resource "helm_release" "kubeflow" {
   depends_on = [module.kube.kube_cluster, nebius_mdb_mysql_cluster.mysql-cluster, nebius_mdb_mysql_user.kubeflowuser, null_resource.db-create, nebius_storage_bucket.kubeflow-bucket, nebius_iam_service_account_static_access_key.sa-static-key, helm_release.argo-cd]
  name       = "kubeflow"
  chart      = "../helm/"
  namespace = "kf-install"
  create_namespace = true

  set {
    name  = "storage_bucket_name"
    value =  nebius_storage_bucket.kubeflow-bucket.bucket
  }

    set {
    name  = "accessKey"
    value =  nebius_iam_service_account_static_access_key.sa-static-key.access_key
  }

    set {
    name  = "secretKey"
    value =  nebius_iam_service_account_static_access_key.sa-static-key.secret_key
  }

  set {
    name  = "mysql_host"
    value =  "c-${nebius_mdb_mysql_cluster.mysql-cluster[0].id}.rw.mdb.nemax.nebius.cloud"
  }

  set {
    name  = "mysql_port"
    value = "3306"
  }


  set {
    name  = "mysql_username"
    value = var.username
  }


  set {
    name  = "mysql_password"
    value = random_password.mysql.result
  }
}


provider "helm" {
    kubernetes {
      host                   = module.kube-inference.kube_external_v4_endpoint
      cluster_ca_certificate = module.kube-inference.kube_cluster_ca_certificate
      token                  = data.nebius_client_config.client.iam_token
    }
}