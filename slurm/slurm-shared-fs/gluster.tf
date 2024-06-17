module "gluster-module" {
  providers = {
    nebius = nebius
  }
  count             = var.shared_fs_type == "gluster" ? 1 : 0
  source            = "../../storage/modules/gluster-module"
  folder_id         = var.folder_id
  ext_subnet_id     = nebius_vpc_subnet.slurm-subnet.id
  disk_size         = var.gluster_disk_size
  storage_nodes     = var.gluster_nodes
  disk_count_per_vm = var.gluster_disks_per_vm
  ssh_pubkey        = local.ssh_public_key
  is_standalone     = false
}
