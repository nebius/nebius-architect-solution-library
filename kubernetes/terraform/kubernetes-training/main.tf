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

module "kuberay" {
  providers = {
    nebius = nebius
    helm   = helm
  }
  
  source                  = "../kuberay"
  count                   = var.kuberay ? 1 : 0
  kube_host               = module.kube.external_v4_endpoint
  cluster_ca_certificate  = module.kube.cluster_ca_certificate
  kube_token              = data.nebius_client_config.client.iam_token
  folder_id               = var.folder_id
  gpu_workers             = var.gpu_nodes_count
}

# File storage disk creation:
resource "nebius_compute_filesystem" "k8s-shared-storage" {
  name       = "${module.kube.cluster_name}-shared-storage"
  folder_id  = var.folder_id
  type       = "network-ssd"
  zone       = "eu-north1-c"
  size       = 1000
  block_size = 4096
}

# Attaching (using ncp cli) file storage into each of the instances in the k8s cluster
resource "null_resource" "attach-filestore" {
  depends_on = [
    nebius_compute_filesystem.k8s-shared-storage,
    module.kube
  ]
  provisioner "local-exec" {
    command = <<EOT
      # Define the subnet_id to filter the instances
      subnet_id="${nebius_vpc_subnet.k8s-subnet.id}"

      # Define the filesystem details to attach
      filesystem_id="${nebius_compute_filesystem.k8s-shared-storage.id}"

      # Fetch the list of instance IDs that are connected to the specified subnet
      instance_ids=$(ncp compute instance list --format json | jq -r ".[] | select(.network_interfaces[].subnet_id == \"$subnet_id\") | .id")

      # Loop through each instance ID and attach the filesystem
      for id in $instance_ids; do
          echo "Attaching filesystem to instance ID: $id"
          ncp compute instance attach-filesystem $id \
              --filesystem-id $filesystem_id
          echo "Filesystem attached to instance ID: $id"
      done

      echo "All operations have been initiated."
EOT
  }
}

# This helm release responsible for mounting the file storage attached to each instance in the k8s cluster:
resource "helm_release" "filestorage-mount-filesystem" {
  name             = "filestorage-mount-filesystem"
  repository       = "../../helm/"
  chart            = "filestorage-mount-filesystem"
  namespace        = "filestorage"
  create_namespace = true
  version          = "0.1.0"
  set {
    name  = "shared_volume_host_path"
    value = "/shared"
  }
  set {
    name = "filesystemId"
    value = nebius_compute_filesystem.k8s-shared-storage.id
  }
}