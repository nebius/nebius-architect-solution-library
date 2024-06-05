resource "nebius_compute_filesystem" "slurm-filestore" {
  count = var.filestore ? 1 : 0
  name  = "slurm-fs"
  type  = "network-ssd"
  zone  = var.zone
  size  = var.fs_size
}