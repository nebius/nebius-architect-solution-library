
module "kube" {
  source = "github.com/nebius/terraform-nb-kubernetes.git?ref=1.0.4"

  network_id = nebius_vpc_network.k8s-network.id

  master_locations = [
    {
      zone      = "eu-north1-c"
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
     "k8s-ng-1g-system" = {
       description = "Kubernetes nodes group 01 with fixed 1 size scaling"
       fixed_scale = {
         size = 3
       }
       node_labels = {
         "group" = "system"
       }
       # node_taints = ["CriticalAddonsOnly=true:NoSchedule"]
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
      node_labels = {
        "group" = "h100-1gpu" 
      	"nebius.com/gpu" = "H100"
      	"nebius.com/gpu-h100" = "H100"
      }		
    }
  }
}
