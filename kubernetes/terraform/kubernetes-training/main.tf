resource "nebius_compute_gpu_cluster" "k8s_cluster" {
  name                          = "k8s-cluster"
  interconnect_type             = "InfiniBand"
  folder_id                     = var.folder_id
  interconnect_physical_cluster = var.gpu_cluster
  zone                          = var.zone_id
}

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
    "k8s-ng-ib-system" = {
      description = "Kubernetes nodes group 01 with fixed 1 size scaling"
      fixed_scale = {
        size = 3
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
      preemptible = true
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


module "gluster-module" {
  providers = {
    nebius = nebius
  }
  count             = var.shared_fs_type == "gluster" ? 1 : 0
  source            = "../../../storage/modules/gluster-module"
  folder_id         = var.folder_id
  ext_subnet_id     = nebius_vpc_subnet.k8s-subnet.id
  disk_size         = var.gluster_disk_size
  storage_nodes     = var.gluster_nodes
  disk_count_per_vm = var.gluster_disks_per_vm
  ssh_pubkey        = var.ssh_public_key
  is_standalone     = false
}

