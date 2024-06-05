module "nfs-module" {
  providers = {
    nebius = nebius
  }
  count        = var.nfs ? 1 : 0
  zone         = var.zone
  source       = "../../storage/modules/nfs-module/"
  folder_id    = var.folder_id
  subnet_id    = nebius_vpc_subnet.slurm-subnet.id
  username     = "storage"
  sshkey       = var.sshkey
  nfs_ip_range = var.segment_ip_addr
  nfs_size     = var.fs_size
}