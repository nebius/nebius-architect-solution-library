module "gluster-fs-cluster" {
  source        = "../../../storage/gluster-fs-cluster"
  ssh_pubkey    = var.ssh_pubkey
  disk_size     = var.disk_size
  storage_nodes = var.storage_nodes
}


resource "nebius_compute_gpu_cluster" "k8s_cluster" {
  name                          = "k8s-cluster"
  interconnect_type             = "InfiniBand"
  interconnect_physical_cluster = "fabric-1"
  zone                          = module.gluster-fs-cluster.subnet.zone
}


module "kube" {
  source = "github.com/nebius/terraform-nb-kubernetes.git?ref=1.0.4"

  network_id = module.gluster-fs-cluster.net.id

  master_locations = [
    {
      zone      = module.gluster-fs-cluster.subnet.zone
      subnet_id = "${module.gluster-fs-cluster.subnet.id}"
    },

  ]

  master_maintenance_windows = [
    {
      day        = "monday"
      start_time = "20:00"
      duration   = "3h"
    }
  ]
  node_groups = {
    "k8s-ng-ib-system" = {
      description = "Kubernetes nodes group 01 with fixed 1 size scaling"
      node_cores  = 40
      node_memory = 120
      fixed_scale = {
        size = var.cpu_nodes_count
      }
      node_labels = {
        "group" = "system"
      }
    }
    "k8s-ng-h100-8gpu1" = {
      description = "Kubernetes nodes h100-8-gpu nodes with autoscaling"
      fixed_scale = {
        size = var.gpu_nodes_count
      }
      gpu_cluster_id  = nebius_compute_gpu_cluster.k8s_cluster.id
      platform_id     = var.platform_id
      gpu_environment = "runc"
      node_cores      = 160
      node_memory     = 1280
      node_gpus       = 8
      disk_type       = "network-ssd-nonreplicated"
      disk_size       = 372
      node_labels     = {
        "group"                     = "h100-8gpu"
        "nebius.com/gpu"            = "H100"
        "nebius.com/gpu-h100-a-llm" = "H100"
      }
    }
  }
}
