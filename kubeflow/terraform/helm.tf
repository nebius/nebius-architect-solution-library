data "nebius_client_config" "client" {}


resource "helm_release" "argo-cd" {
  name       = "argocd"
  repository = "oci://cr.nemax.nebius.cloud/yc-marketplace/nebius/argocd/chart/"
  chart      = "argo-cd"
  namespace = "argocd"
  create_namespace = true
  version = "5.46.8-6"
}


resource "helm_release" "kubeflow" {
  depends_on = [module.kf-cluster.kube_cluster, nebius_mdb_mysql_cluster.mysql-cluster, nebius_mdb_mysql_user.kubeflowuser, null_resource.db-create, nebius_iam_service_account_static_access_key.sa-static-key, helm_release.argo-cd, null_resource.db-create]
  repository = "oci://cr.nemax.nebius.cloud/yc-marketplace/nebius/kubeflow/chart/"
  name       = "kubeflow"
  chart      = "kubeflow"
  namespace = "kf-install"
  create_namespace = true
  version = "0.1.0"

  set {
    name  = "storage_bucket_name"
    value =  "ml-pipeline-${random_string.kf_unique_id.result}"
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
    name  = "use_external_mysql"
    value =  "true"
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
      host                   = module.kf-cluster.kube_external_v4_endpoint
      cluster_ca_certificate = module.kf-cluster.kube_cluster_ca_certificate
      token                  = data.nebius_client_config.client.iam_token
    }
}