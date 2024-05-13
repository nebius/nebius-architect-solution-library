resource "nebius_compute_disk" "glusterdisk_a" {
  count = var.disk_count_per_vm * var.storage_nodes
  zone  = nebius_vpc_subnet.default.zone

  allow_recreate = false
  size           = var.disk_size
  block_size     = var.disk_block_size
  type           = var.disk_type
}
