
module "kube" {
  source = "github.com/nebius/terraform-nb-kubernetes.git?ref=1.0.7"

  network_id = nebius_vpc_network.k8s-network.id
  folder_id  = var.folder_id

  master_locations = [
    {
      zone      = var.zone_id
      subnet_id = "${nebius_vpc_subnet.k8s-subnet.id}"
    },
    {
      zone      = var.zone_id
      subnet_id = "${nebius_vpc_subnet.k8s-subnet.id}"
    },
    {
      zone      = var.zone_id
      subnet_id = "${nebius_vpc_subnet.k8s-subnet.id}"
    },

  ]

  node_locations = [
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
        min     = var.gpu_min_nodes_count
        max     = var.gpu_max_nodes_count
        initial = var.gpu_initial_nodes_count
      }
      platform_id     = var.platform_id
      gpu_environment = var.gpu_env
      node_cores      = 20  // change according to VM size
      node_memory     = 160 // change according to VM size
      node_gpus       = 1
      disk_type       = "network-ssd-nonreplicated"
      disk_size       = 372
      node_labels = {
        "group"               = "h100-1gpu"
        "nebius.com/gpu"      = "H100"
        "nebius.com/gpu-h100" = "H100"
      }
    }
  }

  ssh_username        = var.ssh_username
  ssh_public_key      = var.ssh_public_key
  ssh_public_key_path = var.ssh_public_key_path
}


module "o11y" {
  source = "../o11y"

  providers = {
    nebius = nebius
    helm   = helm
  }

  o11y = merge(
    var.o11y,
    {
      dcgm = {
        enabled = var.o11y.dcgm.enabled,
        node_groups = { for node_group_name, node_group in module.kube.cluster_node_groups :
          node_group_name => {
            gpus              = node_group.instance_template[0].resources[0].gpus
            instance_group_id = node_group.instance_group_id
          }
          if node_group.instance_template[0].resources[0].gpus > 0
        }
      }
    }
  )
  folder_id = var.folder_id
}
