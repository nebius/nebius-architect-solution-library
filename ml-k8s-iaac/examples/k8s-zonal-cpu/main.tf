
module "kube" {
  source = "../../k8s-module/"

  network_id = "btcci5d99ka84l988qvs"

  master_locations = [
    {
      zone      = "eu-north1-c"
      subnet_id = "f8uvrv9g68nqcjiirv0t"
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
      node_taints = ["CriticalAddonsOnly=true:NoSchedule"]
    }
    "k8s-ng-cpu" = {
      description = "Kubernetes CPU nodes with autoscaling"
      auto_scale = {
        min     = 1
        max     = 3
        initial = 1
      }
      platform_id = "standard-v3"
      node_cores  = 28
      node_memory = 168
      disk_type   = "network-ssd-nonreplicated"
      disk_size   = 93

      node_labels = {
        "group" = "cpu"
      }
      node_taints = ["group=cpu:NoSchedule"]
    }

  }
}


