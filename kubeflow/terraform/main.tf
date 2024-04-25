
resource "null_resource" "db-create" {
  depends_on = [nebius_mdb_mysql_cluster.mysql-cluster, nebius_mdb_mysql_user.kubeflowuser]
  provisioner "local-exec" {
    command = <<EOT
      CLUSTER_NAME=${nebius_mdb_mysql_cluster.mysql-cluster[0].name}
      USER_NAME=${var.username}
      BUCKET_NAME="ml-pipeline-${random_string.kf_unique_id.result}"

      ncp managed-mysql database create katib  --cluster-name=$CLUSTER_NAME
      ncp managed-mysql database create kfp_cache  --cluster-name=$CLUSTER_NAME
      ncp managed-mysql database create kfp_metadata  --cluster-name=$CLUSTER_NAME
      ncp managed-mysql database create kfp_pipelines  --cluster-name=$CLUSTER_NAME

      ncp managed-mysql user grant-permission $USER_NAME --cluster-name=$CLUSTER_NAME --database=katib --permissions ALL
      ncp managed-mysql user grant-permission $USER_NAME --cluster-name=$CLUSTER_NAME --database=kfp_cache --permissions ALL
      ncp managed-mysql user grant-permission $USER_NAME --cluster-name=$CLUSTER_NAME --database=kfp_metadata --permissions ALL
      ncp managed-mysql user grant-permission $USER_NAME --cluster-name=$CLUSTER_NAME --database=kfp_pipelines --permissions ALL
      ncp managed-mysql user update $USER_NAME --cluster-name=$CLUSTER_NAME --authentication-plugin=mysql_native_password

EOT
  }
}


module "kf-cluster"{
  source = "../../kubernetes/terraform/kubernetes-inference"
  folder_id = var.folder_id
  zone_id = var.region
  gpu_min_nodes_count = 0
  gpu_max_nodes_count = 8
  gpu_initial_nodes_count = 1
  platform_id = "gpu-h100"
}

# module "kf-cluster"{
#   source = "../../kubernetes/terraform/kubernetes-training"
#   folder_id = var.folder_id
#   zone_id = var.region
#   gpu_nodes_count = 2
#   platform_id = "gpu-h100"
# }
