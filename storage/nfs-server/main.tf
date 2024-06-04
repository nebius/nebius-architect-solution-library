module nfs-module {
  providers = {
    nebius = nebius
  }
  zone = var.zone
  source = "../modules/nfs-module"
  folder_id = var.folder_id
  subnet_id = var.subnet_id
  username = var.username
  sshkey = var.sshkey
  nfs_ip_range = var.nfs_ip_range
  nfs_size = var.nfs_size
}