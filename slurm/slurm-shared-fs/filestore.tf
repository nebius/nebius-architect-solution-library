resource "nebius_compute_filesystem" "slurm-filestore" {
  count     = var.shared_fs_type == "filestore" ? 1 : 0
  name      = "slurm-fs"
  folder_id = var.folder_id
  type      = "network-ssd"
  zone      = var.zone
  size      = var.fs_size
}
