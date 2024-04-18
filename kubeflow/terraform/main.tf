
resource "null_resource" "db-create" {
  depends_on = [nebius_mdb_mysql_cluster.mysql-cluster, nebius_mdb_mysql_user.kubeflowuser]
  provisioner "local-exec" {
    command = <<EOT
      CLUSTER_NAME=${nebius_mdb_mysql_cluster.mysql-cluster[0].name}
      USER_NAME=${var.username}

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

# module "kube" {
#   source = "github.com/nebius/terraform-nb-kubernetes.git?ref=1.0.4"

#   network_id = var.network_id

#   master_locations = [
#     {
#       zone      = "eu-north1-c"
#       subnet_id = var.subnet_id
#     },

#   ]

#   master_maintenance_windows = [
#     {
#       day        = "monday"
#       start_time = "20:00"
#       duration   = "3h"
#     }
#   ]
#   node_groups = {
#      "k8s-ng-1g-system" = {
#        description = "Kubernetes nodes group 01 with fixed 1 size scaling"
#        fixed_scale = {
#          size = 3
#        }
#        nat = true
#        node_labels = {
#          "group" = "system"
#        }
#        # node_taints = ["CriticalAddonsOnly=true:NoSchedule"]
#      }
#     "k8s-ng-h100-1gpu1" = {
#       description = "Kubernetes nodes h100-1-gpu nodes with autoscaling"
#        fixed_scale = {
#          size = 1
#        }
#       platform_id     = "gpu-h100"
#       gpu_environment = "runc"
#       node_cores      = 20 // change according to VM size
#       node_memory     = 160 // change according to VM size
#       node_gpus       = 1
#       disk_type       = "network-ssd-nonreplicated"
#       disk_size       = 372
#       nat = true
#       node_labels = {
#         "group" = "h100-8gpu" 
# 	"cloud.google.com/gke-accelerator" = "any-value"
#       }		
#     }
#   }
# }


module "kube-inference"{
  source = "../../kubernetes/terraform/kubernetes-inference"
  folder_id = var.folder_id
  zone_id = var.region
}