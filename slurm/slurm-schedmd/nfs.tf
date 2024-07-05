module "nfs-module" {
  providers = {
    nebius = nebius
  }
  count        = var.shared_fs_type == "nfs" ? 1 : 0
  zone         = var.zone
  source       = "../../storage/modules/nfs-module/"
  folder_id    = var.folder_id
  subnet_id    = nebius_vpc_subnet.slurm-subnet.id
  username     = "storage"
  sshkey       = local.ssh_public_key
  nfs_ip_range = var.ipv4_range
  nfs_size     = var.fs_size
}
