
module "kube" {
  source = "github.com/nebius/terraform-nb-kubernetes.git?ref=1.0.4"


  network_id = var.network_id

  master_locations = [
    {
      zone      = "eu-north1-c"
      subnet_id = var.subnet_id
    }
  ]

  master_maintenance_windows = [
    {
      day        = "monday"
      start_time = "20:00"
      duration   = "3h"
    }
  ]
  node_groups = {
    "k8s-ng-cpu-system" = {
      description = "Kubernetes nodes group 01 with fixed 1 size scaling"
      fixed_scale = {
        size = 2
      }
      node_labels = {
        "group" = "system"
      }
      node_taints = ["CriticalAddonsOnly=true:NoSchedule"]
    }
    "k8s-ng-cpu" = {
      description = "Kubernetes CPU nodes with autoscaling"
      auto_scale = {
        min     = 0
        max     = 8
        initial = 1
      }
      platform_id = "standard-v3"
      node_cores  = 32
      node_memory = 64
      disk_type   = "network-ssd-nonreplicated"
      disk_size   = 93

      node_labels = {
        "group" = "cpu"
      }
#      node_taints = ["group=cpu:NoSchedule"]
    }

  }
}


