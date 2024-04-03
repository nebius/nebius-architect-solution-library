
data "nebius_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

resource "nebius_compute_instance" "storage_node_a" {
  count                     = var.storage_node_per_zone
  allow_recreate            = true
  allow_stopping_for_update = true
  zone                      = nebius_vpc_subnet.default.zone
  platform_id               = "standard-v2"
  name                      = format("gluster%02d", count.index + 1)
  hostname                  = format("gluster%02d", count.index + 1)

  resources {
    cores         = var.storage_cpu_count
    memory        = var.storage_memory_count
    core_fraction = 100
  }

  network_interface {
    subnet_id = nebius_vpc_subnet.default.id
  }

  boot_disk {
    mode = "READ_WRITE"
    initialize_params {
      image_id = data.nebius_compute_image.ubuntu.image_id
      type     = "network-ssd"
    }
  }

  dynamic "secondary_disk" {
    for_each = range(var.disk_count_per_vm)
    content {
      auto_delete = true
      disk_id     = nebius_compute_disk.glusterdisk_a[count.index * var.disk_count_per_vm + secondary_disk.key].id
    }
  }

  scheduling_policy {
    preemptible = false
  }

  metadata = {
    user-data = templatefile("${path.module}/metadata/cloud-init.yaml", {
      local_pubkey   = file(var.local_pubkey_path)
      master_pubkey  = trimspace(tls_private_key.master_key.public_key_openssh)
      master_privkey = split("\n", tls_private_key.master_key.private_key_openssh)
      nodes_count    = var.storage_node_per_zone
    })
  }
}
