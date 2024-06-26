resource "nebius_compute_filesystem" "k8s-shared-storage" {
  name       = "${module.kube-cluster.kube_cluster_name}-shared-storage"
  folder_id  = var.folder_id
  type       = "network-ssd"
  zone       = "eu-north1-c"
  size       = var.disk_size
  block_size = var.block_size
}

resource "null_resource" "attach-filestore" {
  depends_on = [
    nebius_compute_filesystem.k8s-shared-storage,
    module.kube-cluster,
    module.bastion
  ]
  provisioner "local-exec" {
    command = <<EOT
      # Define the subnet_id to filter the instances
      subnet_id="${module.kube-cluster.subnet_id}"

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

module "kube-cluster" {
  source              = "../kubernetes-training"
  folder_id           = var.folder_id
  zone_id             = var.region
  gpu_nodes_count     = var.node_count
  platform_id         = var.platform_id
  ssh_username        = var.ssh_username
  ssh_public_key      = var.ssh_public_key
  ssh_public_key_path = var.ssh_public_key_path
}

# module "kube-cluster" {
#   source              = "../kubernetes-inference"
#   folder_id           = var.folder_id
#   zone_id             = var.region
#   platform_id         = var.platform_id
#   ssh_username        = var.ssh_username
#   ssh_public_key      = var.ssh_public_key
#   ssh_public_key_path = var.ssh_public_key_path
# }

module "bastion" {
  providers = {
    nebius = nebius
  }

  source                = "../bastion"
  count                 = var.bastion ? 1 : 0
  bastion_prefix        = module.kube-cluster.kube_cluster_name
  folder_id             = var.folder_id
  filesystem_id         = nebius_compute_filesystem.k8s-shared-storage.id
  kubernetes_cluster_id = module.kube-cluster.kube_cluster_id
  subnet_id             = module.kube-cluster.subnet_id
  ssh_username          = var.ssh_username
  ssh_public_key        = var.ssh_public_key
  ssh_public_key_path   = var.ssh_public_key_path
}
