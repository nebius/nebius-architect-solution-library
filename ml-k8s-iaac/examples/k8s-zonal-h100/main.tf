
module "kube" {
  source = "github.com/nebius/terraform-nb-kubernetes.git?ref=1.0.4"

  network_id = var.network_id

  master_locations = [
    {
      zone      = "eu-north1-c"
      subnet_id = var.subnet_id
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
         size = 3
       }
       nat = true
       node_labels = {
         "group" = "system"
       }
       # node_taints = ["CriticalAddonsOnly=true:NoSchedule"]
     }
    "k8s-ng-cpu" = {
      description = "Kubernetes CPU nodes with autoscaling"
      auto_scale = {
        min     = 3
        max     = 8
        initial = 3
      }
      platform_id = "standard-v3"
      node_cores  = 16
      node_memory = 64
      disk_type   = "network-ssd-nonreplicated"
      disk_size   = 93

      node_labels = {
        "group" = "cpu"
      }
#      node_taints = ["group=cpu:NoSchedule"]
    }
    "k8s-ng-h100-1gpu1" = {
      description = "Kubernetes nodes h100-1-gpu nodes with autoscaling"
      auto_scale = {
        min     = 0
        max     = 8
        initial = 0
      }
      platform_id     = "gpu-h100"
      gpu_environment = "runc"
      node_cores      = 20 // change according to VM size
      node_memory     = 160 // change according to VM size
      node_gpus       = 1
      disk_type       = "network-ssd-nonreplicated"
      disk_size       = 372
      nat = true
      node_labels = {
        "group" = "h100-8gpu" 
	"cloud.google.com/gke-accelerator" = "any-value"
      }		
    }
  }
}


