locals {
  ssh_public_key = var.ssh_public_key != null ? var.ssh_public_key : (
  fileexists(var.ssh_public_key_path) ? file(var.ssh_public_key_path) : null)
}

module "gluster-module" {
  providers = {
    nebius = nebius
  }
  count             = var.shared_fs_type == "gluster" ? 1 : 0
  source            = "../../../storage/modules/gluster-module"
  folder_id         = var.folder_id
  ext_subnet_id     = nebius_vpc_subnet.k8s-subnet-1.id
  disk_size         = var.gluster_disk_size
  storage_nodes     = var.gluster_nodes
  disk_count_per_vm = var.gluster_disks_per_vm
  ssh_pubkey        = local.ssh_public_key
  is_standalone     = false
}

resource "helm_release" "mount-filesystem" {
  #count             = var.shared_fs_type == "gluster" ? 1 : 0
  depends_on       = [module.kube]
  repository       = "../../helm/"
  name             = "gluster-mount-filesystem"
  chart            = "gluster-mount-filesystem"
  namespace        = "glusterfs"
  create_namespace = true
  version          = "0.1.0"

  set {
    name  = "shared_volume_host_path"
    value = "gluster01"
  }

  set {
    name  = "glusterfs_hostname"
    value = "/shared"
  }
}
