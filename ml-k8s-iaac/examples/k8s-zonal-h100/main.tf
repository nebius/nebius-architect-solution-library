
module "kube" {
  source = "../../k8s-module/"

  network_id = "btcci5d99ka84l988qvs"

  master_locations = [
    {
      zone      = "eu-north1-c"
      subnet_id = "f8ut3srsmjrlor5uko84"
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
    "k8s-ng-system" = {
      description = "Kubernetes nodes group 01 with fixed 1 size scaling"
      fixed_scale = {
        size = 2
      }
      nat = true
      node_labels = {
        "group" = "system"
      }
      # node_taints = ["CriticalAddonsOnly=true:NoSchedule"]
    }
    "k8s-ng-h100-8gpu1" = {
      description = "Kubernetes nodes h100-8-gpu nodes with autoscaling"
      auto_scale = {
        min     = 2
        max     = 3
        initial = 2
      }
      platform_id     = "gpu-h100"
      gpu_environment = "runc"
      node_cores      = 20
      node_memory     = 160
      node_gpus       = 1
      disk_type       = "network-ssd-nonreplicated"
      disk_size       = 372

      node_labels = {
        "group" = "h100-8gpu"
      }
    }
  }
}


