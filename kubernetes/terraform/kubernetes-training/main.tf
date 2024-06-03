resource "nebius_compute_gpu_cluster" "k8s_cluster" {
  name                          = "k8s-cluster"
  interconnect_type             = "InfiniBand"
  folder_id                     = var.folder_id
  interconnect_physical_cluster = "fabric-1"
  zone                          = var.zone_id
}

module "kube" {
  source = "github.com/nebius/terraform-nb-kubernetes.git?ref=1.0.6"

  network_id = nebius_vpc_network.k8s-network.id
  folder_id  = var.folder_id

  master_locations = [
    {
      zone      = var.zone_id
      subnet_id = "${nebius_vpc_subnet.k8s-subnet.id}"
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
      fixed_scale = {
        size = 2
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
      node_labels = {
        "group"                     = "h100-8gpu"
        "nebius.com/gpu"            = "H100"
        "nebius.com/gpu-h100-a-llm" = "H100"
      }
    }
  }

  ssh_username        = var.ssh_username
  ssh_public_key      = var.ssh_public_key
  ssh_public_key_path = var.ssh_public_key_path
}
